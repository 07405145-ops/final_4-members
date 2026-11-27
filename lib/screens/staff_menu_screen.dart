import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/menu_provider.dart';
import '../widgets/atoms/empty_state.dart';
import '../widgets/atoms/loading_state.dart';
import '../widgets/atoms/peso_text.dart';

class StaffMenuScreen extends StatelessWidget {
  const StaffMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    if (menu.loading) {
      return Center(child: LoadingState(onRefresh: menu.refresh));
    }
    if (menu.error != null) return EmptyState('Error: ${menu.error}');
    if (menu.items.isEmpty) {
      return Center(
        child: FilledButton(
          onPressed: menu.seedMenu,
          child: const Text('Add sample menu'),
        ),
      );
    }
    return ListView(children: [
      for (final m in menu.items)
        SwitchListTile(
          title: Text(m.name),
          subtitle: PesoText(m.price),
          value: m.available,
          onChanged: (v) => menu.setAvailability(m.id, v),
        ),
    ]);
  }
}
