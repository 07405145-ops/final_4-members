import 'package:flutter/material.dart';

import '../atoms/peso_text.dart';
import '../atoms/primary_button.dart';
import '../molecules/app_text_field.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.noteController,
    required this.total,
    required this.placing,
    required this.onPlace,
  });

  final TextEditingController noteController;
  final double total;
  final bool placing;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        AppTextField(
            controller: noteController,
            label: 'Pickup note (e.g. "Recess, 10:00 AM")'),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Text('Total: ', style: TextStyle(fontSize: 18)),
            PesoText(total,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          PrimaryButton(label: 'Place order', loading: placing, onPressed: onPlace),
        ]),
      ]),
    );
  }
}
