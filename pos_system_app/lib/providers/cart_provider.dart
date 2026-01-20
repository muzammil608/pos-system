import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => _orders;

  void addOrder({
    required List<Map<String, dynamic>> items,
    required double total,
  }) {
    _orders.add({
      "id": DateTime.now().millisecondsSinceEpoch,
      "items": items,
      "total": total,
      "status": "pending",
      "time": DateTime.now(),
    });

    notifyListeners();
  }

  void markReady(int id) {
    final index = _orders.indexWhere((o) => o["id"] == id);
    if (index != -1) {
      _orders[index]["status"] = "ready";
      notifyListeners();
    }
  }

  double get todaySales {
    double sum = 0;
    for (var o in _orders) {
      sum += (o["total"] as num).toDouble();
    }
    return sum;
  }

  void clearAll() {
    _orders.clear();
    notifyListeners();
  }
}
