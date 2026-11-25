import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'staff_menu_screen.dart';
import 'staff_orders_screen.dart';

/// Staff shell: tabs for incoming Orders and Menu availability.
class StaffHome extends StatelessWidget {
  const StaffHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CanteenGo Staff'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Orders'), Tab(text: 'Menu')]),
        ),
        body: const TabBarView(children: [StaffOrdersScreen(), StaffMenuScreen()]),
      ),
    );
  }
}
