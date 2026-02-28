import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => _orders;

  List<Map<String, dynamic>> get pendingOrders =>
      _orders.where((o) => o["status"] == "pending").toList();

  List<Map<String, dynamic>> get readyOrders =>
      _orders.where((o) => o["status"] == "ready").toList();

  final _ordersRef = FirebaseFirestore.instance.collection('orders');

  CartProvider() {
    listenOrders();
  }

  Future<void> addOrder({
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    final docRef = _ordersRef.doc();

    final orderData = {
      "id": docRef.id,
      "items": items,
      "total": total,
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    };

    await docRef.set(orderData);
  }

  void listenOrders() {
    _ordersRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _orders.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        _orders.add({
          "id": data['id'] ?? doc.id,
          "items": data['items'] ?? [],
          "total": (data['total'] ?? 0).toDouble(),
          "status": data['status'] ?? "pending",
          "timestamp": data['timestamp'],
        });
      }

      notifyListeners();
    });
  }

  Future<void> markReady(String id) async {
    await _ordersRef.doc(id).update({"status": "ready"});
  }

  double get todaySales {
    double sum = 0;
    for (var o in _orders) {
      sum += (o["total"] ?? 0).toDouble();
    }
    return sum;
  }

  void clearAll() {
    _orders.clear();
    notifyListeners();
  }
}
