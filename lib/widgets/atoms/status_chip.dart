import 'package:flutter/material.dart';

import '../../models/order_model.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.pending => Colors.grey,
      OrderStatus.preparing => Colors.blue,
      OrderStatus.ready => Colors.green,
      _ => Colors.black54,
    };
    return Chip(
      label: Text(status.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 11)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
