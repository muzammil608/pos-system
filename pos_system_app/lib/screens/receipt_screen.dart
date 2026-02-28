import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Receipt"),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No receipt available"));
          }

          final orderData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final List<dynamic> items = orderData["items"] ?? [];
          const double fbrFee = 1.0;
          double subTotal = 0;

          return Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 380,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "ORION PIZZA RESTAURANT",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text("FBR POS Registered",
                            style: TextStyle(color: Colors.grey)),
                        const Divider(height: 30, thickness: 1.2),

                        // Items list
                        ...items.map((item) {
                          final name = item["name"] ?? "Item";
                          final qty = (item["qty"] ?? 0) as int;
                          final price = (item["price"] ?? 0).toDouble();
                          final imageUrl = item["imageUrl"] ?? "";
                          final itemTotal = qty * price;
                          subTotal += itemTotal;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                if (imageUrl.isNotEmpty)
                                  Image.network(imageUrl,
                                      width: 40, height: 40, fit: BoxFit.cover),
                                if (imageUrl.isNotEmpty)
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: Text("$name x$qty",
                                      style: const TextStyle(fontSize: 16)),
                                ),
                                Text("Rs ${itemTotal.toStringAsFixed(0)}",
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          );
                        }).toList(),

                        const Divider(height: 30),
                        _priceRow("Subtotal", subTotal),
                        _priceRow("FBR POS Fee", fbrFee),
                        const Divider(height: 30, thickness: 1.2),
                        _priceRow("Grand Total", subTotal + fbrFee,
                            isBold: true),
                        const SizedBox(height: 25),
                        const Text("Thanks for visiting us!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Come again 😊"),
                        const Text("Orion-Solutions"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("Rs ${value.toStringAsFixed(0)}",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
