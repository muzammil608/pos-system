import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/cart_provider.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final order =
        cartProvider.orders.isNotEmpty ? cartProvider.orders.last : null;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Receipt")),
        body: const Center(child: Text("No receipt available")),
      );
    }

    final List<dynamic> itemsList = order["items"] ?? [];
    const double fbrFee = 1.0;
    double subTotal = 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Receipt"),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Center(
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text("FBR POS Registered",
                        style: TextStyle(color: Colors.grey)),
                    const Divider(height: 30, thickness: 1.2),

                    /// ITEMS LIST (Restored your specific row styling)
                    ...itemsList.map((item) {
                      final String name = item["name"] ?? "Item";
                      final int qty = (item["qty"] ?? 0) as int;
                      final double price = (item["price"] ?? 0).toDouble();
                      final double itemTotal = qty * price;

                      subTotal += itemTotal;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text("$name x$qty",
                                    style: const TextStyle(fontSize: 16))),
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

                    _priceRow(
                      "Grand Total",
                      subTotal + fbrFee,
                      isBold: true,
                    ),

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
      ),
    );
  }

  // Helper widget to keep the rows consistent with your previous style
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
