import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pastifyhubstores/test.dart';

import '../accounts/homepage.dart';
import '../cart/carts.dart';
import '../cart/homepage.dart';
import '../category/homepage.dart';
import 'hometab/hometab.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CartService _cartService = CartService();
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

  final List<Widget> _pages = const [



    Hometab(),
    Categories(),

    Carts(),

    Accounts(),


  ];


    return Scaffold(
      appBar: AppBar(
        title: const Text("PastiHub Stores"),

        actions: [
          if (userId != null)
            StreamBuilder<QuerySnapshot>(
              stream: _cartService.getCartStream(userId),
              builder: (context, snapshot) {
                int count = snapshot.data?.docs.length ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const Carts()));
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _pages[_currentIndex],

      // Custom Bottom Nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
            items: [
              _navBarItem(Icons.home, "Home", 0),
              _navBarItem(Icons.category, "Categories", 1),
              _navBarItem(Icons.shopping_cart, "Carts", 2),
              _navBarItem(Icons.account_circle, "Accounts", 4),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navBarItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _currentIndex == index
              ? Colors.deepOrange.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: _currentIndex == index ? 28 : 24,
        ),
      ),
      label: label,
    );
  }
}
