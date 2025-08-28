import 'package:flutter/material.dart';
import 'package:pastifyhubstores/test.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Categories Page')),
    Center(child: Text('Categories Page')),
    Center(child: Text('Carts Page')),
    Center(child: Text('Wishlist Page')),
    Center(child: Text('Accounts Pages')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _navBarItem(Icons.favorite, "Wishlist", 3),
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
