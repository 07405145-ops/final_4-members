import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/atoms/empty_state.dart';
import '../widgets/atoms/loading_state.dart';
import '../widgets/molecules/menu_tile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    if (menu.loading) {
      return Center(
        child: LoadingState(
          showIndicator: false,
          message: 'Loading menu...',
          onRefresh: menu.refresh,
        ),
      );
    }
    if (menu.error != null) return EmptyState('Error: ${menu.error}');
    if (menu.items.isEmpty)
      return const EmptyState('Menu is empty. Ask canteen staff to add items.');

    return ListView.builder(
      itemCount: menu.items.length,
      itemBuilder: (context, i) {
        final item = menu.items[i];
        return MenuTile(
          item: item,
          onAdd: () {
            context.read<CartProvider>().add(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} added'),
                duration: const Duration(milliseconds: 800),
              ),
            );
          },
        );
      },
    );
  }
}
