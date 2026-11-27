import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/atoms/empty_state.dart';
import '../widgets/atoms/loading_state.dart';
import '../widgets/organisms/order_card.dart';

class StaffOrdersScreen extends StatelessWidget {
  const StaffOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    if (p.loading) return Center(child: LoadingState(onRefresh: p.refresh));
    if (p.error != null) return EmptyState('Error: ${p.error}');
    if (p.orders.isEmpty) return const EmptyState('No active orders');

    return ListView.builder(
      itemCount: p.orders.length,
      itemBuilder: (_, i) {
        final order = p.orders[i];
        final next = OrderStatus.next(order.status);
        return OrderCard(
          order: order,
          showCustomer: true,
          action: next == null
              ? null
              : FilledButton(
                  onPressed: () => p.advance(order),
                  child: Text('Mark $next'),
                ),
        );
      },
    );
  }
}
