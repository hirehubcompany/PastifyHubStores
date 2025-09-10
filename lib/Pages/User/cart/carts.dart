// cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCartStream(String userId) =>
      _db.collection('users').doc(userId).collection('cart').snapshots();

  Future<void> addToCart(BuildContext context, String userId, Map<String, dynamic> product) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product['id']) // you can still use productId as docId when adding
        .set(product, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  Future<void> removeFromCart(String userId, String cartDocId) async {
    await _db.collection('users').doc(userId).collection('cart').doc(cartDocId).delete();
  }
}
