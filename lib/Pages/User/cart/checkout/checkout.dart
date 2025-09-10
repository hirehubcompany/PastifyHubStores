import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'congratulations.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController momoNumberController = TextEditingController();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  double subtotal = 0.0;
  double deliveryFee = 0.0;
  double total = 0.0;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          subtotal = 0.0;
          for (var doc in cartItems) {
            final data = doc.data() as Map<String, dynamic>;
            subtotal += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          }
          total = subtotal + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item =
                    cartItems[index].data() as Map<String, dynamic>;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item['image'] != null
                              ? Image.network(
                            item['image'],
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 55,
                            height: 55,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image,
                                color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          item['productName'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: Text(
                          "GHS ${(item['price'] ?? 0).toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "x${item['quantity'] ?? 1}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Delivery Address
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: "Enter your delivery address",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.location_on_outlined,
                            color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fixed Payment Method
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_iphone,
                              color: Colors.orange),
                          const SizedBox(width: 10),
                          const Text(
                            "MTN Mobile Money",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // MoMo Number Input
                    TextField(
                      controller: momoNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Enter MTN MoMo Number",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.payment,
                            color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Summary
                    _buildSummaryRow("Subtotal", subtotal),
                    _buildSummaryRow("Delivery Fee", deliveryFee,
                        isFree: deliveryFee == 0),
                    const Divider(thickness: 1),
                    _buildSummaryRow("Total", total, isBold: true),
                    const SizedBox(height: 16),

                    // Confirm Order Button
                    ElevatedButton(
                      onPressed: () async {
                        if (addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text("Please enter delivery address")),
                          );
                          return;
                        }
                        if (momoNumberController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text("Please enter MTN MoMo number")),
                          );
                          return;
                        }
                        await _confirmOrder(
                            user.uid, cartItems, momoNumberController.text);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return const Congratulations();
                            }));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Confirm Order - GHS ${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value,
      {bool isBold = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14)),
          Text(
            isFree ? "FREE" : "GHS ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isFree ? Colors.green : Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(
      String userId, List<QueryDocumentSnapshot> cartItems, String momoNumber) async {
    final orderRef = _db.collection('orders').doc();
    await orderRef.set({
      'userId': userId,
      'address': addressController.text.trim(),
      'paymentMethod': 'MTN Mobile Money',
      'momoNumber': momoNumber.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'items': cartItems.map((doc) => doc.data()).toList(),
      'total': total,
    });

    // Clear cart
    for (var doc in cartItems) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully")),
    );
  }
}
