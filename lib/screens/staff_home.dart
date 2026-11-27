import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation_refresh_observer.dart';
import '../providers/auth_provider.dart';
import 'user_profile_screen.dart';
import 'staff_menu_screen.dart';
import 'staff_orders_screen.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({super.key});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  final _changingTab = ValueNotifier(false);
  final _selectedTab = ValueNotifier(0);

  @override
  void dispose() {
    _changingTab.dispose();
    _selectedTab.dispose();
    super.dispose();
  }

  Future<void> _selectTab(int index) async {
    if (index == _selectedTab.value || _changingTab.value) return;
    _changingTab.value = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _selectedTab.value = index;
    _changingTab.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CanteenGo Staff'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: ValueListenableBuilder<int>(
            valueListenable: _selectedTab,
            builder: (context, selectedTab, _) => Row(
              children: [
                _StaffTabButton(
                  label: 'Orders',
                  isSelected: selectedTab == 0,
                  onPressed: () => _selectTab(0),
                ),
                _StaffTabButton(
                  label: 'Menu',
                  isSelected: selectedTab == 1,
                  onPressed: () => _selectTab(1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _changingTab,
        builder: (context, changingTab, _) => NavigationLoadingBody(
          child: changingTab
              ? const Center(child: CircularProgressIndicator())
              : ValueListenableBuilder<int>(
                  valueListenable: _selectedTab,
                  builder: (context, selectedTab, _) => selectedTab == 0
                      ? const StaffOrdersScreen()
                      : const StaffMenuScreen(),
                ),
        ),
      ),
    );
  }
}

class _StaffTabButton extends StatelessWidget {
  const _StaffTabButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 48,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Container(
                height: 2,
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
