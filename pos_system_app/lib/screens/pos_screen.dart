import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, int> cart = {};

  int get total {
    int sum = 0;
    cart.forEach((name, qty) {
      final product = _products.firstWhere((p) => p['name'] == name);
      sum += (product['price'] as int) * qty;
    });
    return sum;
  }

  List<Map<String, dynamic>> _products = [];

  void addToCart(String name) {
    setState(() {
      cart[name] = (cart[name] ?? 0) + 1;
    });
  }

  Future<void> confirmOrder() async {
    if (cart.isEmpty) return;

    final provider = Provider.of<CartProvider>(context, listen: false);

    List<Map<String, dynamic>> items = [];

    cart.forEach((name, qty) {
      final product = _products.firstWhere((p) => p["name"] == name);
      items.add({
        "name": name,
        "price": product["price"],
        "qty": qty,
      });
    });

    await provider.addOrder(
      items: items,
      total: total.toDouble(),
    );

    setState(() {
      cart.clear();
    });

    Navigator.pushNamed(context, "/receipt");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("POS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.kitchen),
            onPressed: () => Navigator.pushNamed(context, "/kitchen"),
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.pushNamed(context, "/admin"),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getProductsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          _products = snapshot.data!.docs
              .map((doc) => {
                    "id": doc.id,
                    "name": doc['name'],
                    "price": doc['price'],
                    "imageUrl": doc['imageUrl'],
                  })
              .toList();

          return Row(
            children: [
              /// PRODUCTS GRID
              Expanded(
                flex: 2,
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (_, i) {
                    final product = _products[i];
                    return Card(
                      child: InkWell(
                        onTap: () => addToCart(product["name"]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              product["imageUrl"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            Text(product["name"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Rs ${product["price"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// CART
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text("Cart",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: cart.entries.map((entry) {
                          return ListTile(
                            title: Text(entry.key),
                            trailing: Text("x${entry.value}"),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Total: Rs $total",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: confirmOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Confirm Order",
                            style: TextStyle(fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
