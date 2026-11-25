import 'package:flutter/material.dart';

import '../../models/menu_item.dart';
import '../atoms/peso_text.dart';

class MenuTile extends StatelessWidget {
  const MenuTile({super.key, required this.item, required this.onAdd});
  final MenuItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('${item.category}${item.available ? '' : '  •  Sold out'}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        PesoText(item.price),
        IconButton(
          icon: const Icon(Icons.add_circle),
          color: Theme.of(context).colorScheme.primary,
          onPressed: item.available ? onAdd : null,
        ),
      ]),
    );
  }
}
