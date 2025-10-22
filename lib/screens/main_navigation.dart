import 'package:flutter/material.dart';
import '../widgets/liquid_bottom_nav.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          ProductListScreen(),
          CartScreen(),
          WishlistScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: LiquidBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        items: const [
          LiquidBottomNavigationBarItem(
            icon: Icons.home,
            label: 'Home',
          ),
          LiquidBottomNavigationBarItem(
            icon: Icons.shopping_cart,
            label: 'Cart',
          ),
          LiquidBottomNavigationBarItem(
            icon: Icons.favorite,
            label: 'Wishlist',
          ),
          LiquidBottomNavigationBarItem(
            icon: Icons.person_outline,
            label: 'Profile',
          ),
        ],
        liquidColor: Colors.blue[800]!,
        backgroundColor: Colors.white,
        borderRadius: 20.0,
      ),
    );
  }
}