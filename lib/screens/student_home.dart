import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation_refresh_observer.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'user_profile_screen.dart';
import 'cart_screen.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});
  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final _selectedTab = ValueNotifier(0);
  final _activeTab = ValueNotifier(0);
  bool _changingTab = false;
  static const _pages = [MenuScreen(), CartScreen(), OrdersScreen()];

  Future<void> _selectTab(int index) async {
    if (index == _selectedTab.value || _changingTab) return;
    _changingTab = true;
    _selectedTab.value = index;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    _activeTab.value = index;
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    _changingTab = false;
  }

  @override
  void dispose() {
    _selectedTab.dispose();
    _activeTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CanteenGo'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        notificationPredicate: (_) => false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'User profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
            icon: UserProfileAvatar(
              uid: user?.uid ?? '',
              name: user?.displayName,
            ),
          ),
        ],
      ),
      body: NavigationLoadingBody(
        child: ValueListenableBuilder<int>(
          valueListenable: _activeTab,
          builder: (context, tab, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
            child: KeyedSubtree(key: ValueKey(tab), child: _pages[tab]),
          ),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedTab,
        builder: (context, tab, _) => NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: _selectTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long),
              label: 'My Orders',
            ),
          ],
        ),
      ),
    );
  }
}
