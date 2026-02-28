import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(
            child: Text("Access Denied", style: TextStyle(fontSize: 22))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: "Employees"), Tab(text: "Products")],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Employees Tab
                  StreamBuilder(
                    stream: _firestoreService.getUsersStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());

                      final users = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (_, i) {
                          final user = users[i];
                          return ListTile(
                            title: Text(user['name']),
                            subtitle: Text(user['role']),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditUserDialog(
                                    user.id, user['name'], user['role']);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Products Tab
                  StreamBuilder(
                    stream: _firestoreService.getProductsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());

                      final products = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (_, i) {
                          final product = products[i];
                          return ListTile(
                            leading: Image.network(product['imageUrl'],
                                width: 40, height: 40, fit: BoxFit.cover),
                            title: Text(product['name']),
                            subtitle: Text("Rs ${product['price']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditProductDialog(
                                    product.id,
                                    product['name'],
                                    product['price'],
                                    product['imageUrl']);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Decide which tab is active
          final tab = DefaultTabController.of(context)?.index ?? 0;
          if (tab == 0) {
            _showAddUserDialog();
          } else {
            _showAddProductDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    String role = 'employee';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Employee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: "employee", child: Text("Employee")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (v) {
                if (v != null) role = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                final uid = DateTime.now().millisecondsSinceEpoch.toString();
                FirestoreService().addUser(uid, nameController.text, role);
                Navigator.pop(context);
              },
              child: const Text("Add")),
        ],
      ),
    );
  }

  void _showEditUserDialog(String uid, String name, String role) {
    final nameController = TextEditingController(text: name);
    String selectedRole = role;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Employee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            DropdownButton<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: "employee", child: Text("Employee")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (v) {
                if (v != null) selectedRole = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              FirestoreService()
                  .updateUser(uid, nameController.text, selectedRole);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number),
            TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Image URL")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              FirestoreService().addProduct(
                  nameController.text,
                  double.tryParse(priceController.text) ?? 0,
                  imageController.text);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(
      String id, String name, double price, String imageUrl) {
    final nameController = TextEditingController(text: name);
    final priceController = TextEditingController(text: price.toString());
    final imageController = TextEditingController(text: imageUrl);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number),
            TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Image URL")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              FirestoreService().updateProduct(
                  id,
                  nameController.text,
                  double.tryParse(priceController.text) ?? 0,
                  imageController.text);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
