import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/cart_provider.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allOrders = context.watch<CartProvider>().orders;
    final pendingOrders =
        allOrders.where((o) => o["status"] == "pending").toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text("Kitchen Display")),
      body: pendingOrders.isEmpty
          ? const Center(child: Text("No Pending Orders"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: pendingOrders.length,
              itemBuilder: (_, i) {
                final order = pendingOrders[i];
                final List<dynamic> items = order["items"] ?? [];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Order #${order["id"].toString().substring(order["id"].toString().length - 5)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            children: items
                                .map((item) => Text(
                                    "${item["name"]} x${item["qty"]}",
                                    style: const TextStyle(fontSize: 16)))
                                .toList(),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                            onPressed: () => context
                                .read<CartProvider>()
                                .markReady(order["id"]),
                            child: const Text("READY",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
