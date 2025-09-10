import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> addToCart(BuildContext context, String userId, Map<String, dynamic> product) async {
  final cartRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart');

  try {
    final existing = await cartRef
        .where('productId', isEqualTo: product['id'])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update quantity
      await existing.docs.first.reference.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // Add new product
      await cartRef.add({
        'productId': product['id'],
        'productName': product['productName'],
        'price': product['price'],
        'image': product['images'] != null && product['images'].isNotEmpty
            ? product['images'][0]
            : '',
        'quantity': 1,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product['productName']} added to cart")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error adding to cart: $e")),
    );
  }
}
