import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/atoms/empty_state.dart';
import '../widgets/molecules/cart_tile.dart';
import '../widgets/organisms/cart_summary.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _note = TextEditingController();
  bool _placing = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _placing = true);
    try {
      await orders.placeOrder(
        lines: cart.lines,
        total: cart.total,
        note: _note.text.trim(),
      );
      if (!mounted) return;
      cart.clear();
      _note.clear();
      messenger.showSnackBar(const SnackBar(content: Text('Order placed! Check My Orders.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.isEmpty) return const EmptyState('Your cart is empty');

    return Column(children: [
      Expanded(
        child: ListView(children: [
          for (final line in cart.lines)
            CartTile(
              line: line,
              onAdd: () => cart.add(line.item),
              onRemove: () => cart.remove(line.item),
            ),
        ]),
      ),
      CartSummary(
        noteController: _note,
        total: cart.total,
        placing: _placing,
        onPlace: _place,
      ),
    ]);
  }
}
