import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/cart_provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final List<Map<String, dynamic>> menuItems = [
    {"name": "Burger", "price": 500, "img": "burger.png"},
    {"name": "Pizza", "price": 1200, "img": "pizza.png"},
    {"name": "Fries", "price": 300, "img": "fries.png"},
    {"name": "Drink", "price": 200, "img": "drink.png"},
    {"name": "Shawarma", "price": 450, "img": "shawarma.png"},
    {"name": "Pasta", "price": 500, "img": "pasta.png"},
  ];

  final Map<String, int> cart = {};

  int get total {
    int sum = 0;
    cart.forEach((key, qty) {
      final item = menuItems.firstWhere((e) => e["name"] == key);
      sum += (item["price"] as int) * qty;
    });
    return sum;
  }

  void addToCart(String name) {
    setState(() => cart[name] = (cart[name] ?? 0) + 1);
  }

  void confirmOrder(BuildContext context) {
    if (cart.isEmpty) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    List<Map<String, dynamic>> itemsForReceipt = [];

    cart.forEach((name, qty) {
      final menuItem = menuItems.firstWhere((e) => e["name"] == name);
      itemsForReceipt.add({
        "name": name,
        "price": (menuItem["price"] as int).toDouble(),
        "qty": qty,
      });
    });

    cartProvider.addOrder(items: itemsForReceipt, total: total.toDouble());
    setState(() => cart.clear());
    Navigator.pushNamed(context, '/receipt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("POS System"),
        actions: [
          IconButton(
              icon: const Icon(Icons.kitchen),
              onPressed: () => Navigator.pushNamed(context, '/kitchen')),
          IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.pushNamed(context, '/admin')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: menuItems.length,
                itemBuilder: (_, i) {
                  final item = menuItems[i];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () => addToCart(item["name"]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.asset(
                              "assets/images/${item["img"]}",
                              fit:
                                  BoxFit.cover, // Makes image fill the card top
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.fastfood, size: 50),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(item["name"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text("Rs ${item["price"]}",
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Order Summary",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          children: cart.entries.map((e) {
                            final item =
                                menuItems.firstWhere((i) => i["name"] == e.key);
                            return ListTile(
                              title: Text(e.key),
                              trailing: Text("Rs ${item["price"] * e.value}"),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(),
                      Text("Total: Rs $total",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary),
                          onPressed: () => confirmOrder(context),
                          child: const Text("Confirm Order",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
