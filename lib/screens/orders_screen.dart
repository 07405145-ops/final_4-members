import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/atoms/empty_state.dart';
import '../widgets/atoms/loading_state.dart';
import '../widgets/organisms/order_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderProvider>();
    if (p.loading) {
      return Center(
        child: LoadingState(
          showIndicator: false,
          message: 'Loading orders...',
          onRefresh: p.refresh,
        ),
      );
    }
    if (p.error != null) return EmptyState('Error: ${p.error}');
    if (p.orders.isEmpty) return const EmptyState('No orders yet');

    return ListView.builder(
      itemCount: p.orders.length,
      itemBuilder: (_, i) => OrderCard(order: p.orders[i]),
    );
  }
}
