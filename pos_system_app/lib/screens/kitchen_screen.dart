import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);

    final pendingOrders = provider.pendingOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen"),
      ),
      body: pendingOrders.isEmpty
          ? const Center(
              child: Text(
                "No Pending Orders",
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: pendingOrders.length,
              itemBuilder: (_, index) {
                final order = pendingOrders[index];

                final items = order["items"] as List<dynamic>? ?? [];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID: ${order["id"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...items.map((item) {
                          return Text("${item["name"]} x${item["qty"]}");
                        }),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            provider.markReady(order["id"]);
                          },
                          child: const Text("Mark Ready"),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
