import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USERS
  Future<void> addUser(String uid, String name, String role) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(String uid, String name, String role) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'role': role,
    });
  }

  Stream<QuerySnapshot> getUsersStream() => _db
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots();

  // PRODUCTS
  Future<void> addProduct(String name, double price, String imageUrl) async {
    await _db.collection('products').add({
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(
      String id, String name, double price, String imageUrl) async {
    await _db.collection('products').doc(id).update({
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  Stream<QuerySnapshot> getProductsStream() => _db
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots();

  // ORDERS (unchanged)
  final _ordersRef = FirebaseFirestore.instance.collection('orders');
  Future<void> addOrder(Map<String, dynamic> orderData) async {
    await _ordersRef.doc().set(orderData);
  }

  Stream<QuerySnapshot> getOrdersStream() =>
      _ordersRef.orderBy('timestamp', descending: true).snapshots();
}
