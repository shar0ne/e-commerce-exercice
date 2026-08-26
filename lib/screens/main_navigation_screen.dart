import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../widgets/animated_cart_badge.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'home_catalog_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeCatalogScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favoriteCount = ref.watch(favoritesNotifierProvider.select((set) => set.length));

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Catalogue',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favoriteCount > 0,
                label: Text('$favoriteCount'),
                backgroundColor: const Color(0xFFEC4899),
                child: const Icon(Icons.favorite_outline_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: favoriteCount > 0,
                label: Text('$favoriteCount'),
                backgroundColor: const Color(0xFFEC4899),
                child: const Icon(Icons.favorite_rounded),
              ),
              label: 'Favoris',
            ),
            const NavigationDestination(
              icon: AnimatedCartBadge(
                child: Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: AnimatedCartBadge(
                child: Icon(Icons.shopping_bag_rounded),
              ),
              label: 'Panier',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
