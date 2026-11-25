import 'package:flutter/material.dart';

import '../../models/cart_line.dart';
import '../atoms/peso_text.dart';

class CartTile extends StatelessWidget {
  const CartTile({
    super.key,
    required this.line,
    required this.onAdd,
    required this.onRemove,
  });

  final CartLine line;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(line.item.name),
      subtitle: PesoText(line.subtotal),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onRemove),
        Text('${line.qty}'),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAdd),
      ]),
    );
  }
}
