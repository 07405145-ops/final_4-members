import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../atoms/peso_text.dart';
import '../atoms/status_chip.dart';

/// Used by students (read-only) and staff (with an action button).
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.showCustomer = false,
    this.action,
  });

  final OrderModel order;
  final bool showCustomer;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                showCustomer ? order.userEmail : 'Order #${order.shortId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            StatusChip(order.status),
          ]),
          const SizedBox(height: 8),
          for (final i in order.items) Text('${i.qty}x ${i.name}'),
          if (order.pickupNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Pickup: ${order.pickupNote}',
                style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          Row(children: [
            PesoText(order.total, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (action != null) action!,
          ]),
        ]),
      ),
    );
  }
}
