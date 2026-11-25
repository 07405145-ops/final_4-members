import 'package:flutter/material.dart';

class PesoText extends StatelessWidget {
  const PesoText(this.amount, {super.key, this.style});
  final double amount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) =>
      Text('₱${amount.toStringAsFixed(2)}', style: style);
}
