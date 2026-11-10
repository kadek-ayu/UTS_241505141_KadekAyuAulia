
import 'package:flutter/material.dart';

import '../widgets/responsive_content.dart';
import 'home/home_screen.dart';
import 'medicines/medicine_list_screen.dart';
import 'medicines/favorite_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    MedicineListScreen(),
    FavoriteScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildPageContent() {
    return ResponsiveContent(
      child: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 1000;

        if (isWideScreen) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: _changePage,
                  labelType: NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.medication_outlined),
                      selectedIcon: Icon(Icons.medication),
                      label: Text('Katalog'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.star_border),
                      selectedIcon: Icon(Icons.star),
                      label: Text('Tersimpan'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.shopping_cart_outlined),
                      selectedIcon: Icon(Icons.shopping_cart),
                      label: Text('Keranjang'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _buildPageContent(),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: _buildPageContent(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: _changePage,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.medication_outlined),
                selectedIcon: Icon(Icons.medication),
                label: 'Katalog',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: 'Tersimpan',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Keranjang',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
