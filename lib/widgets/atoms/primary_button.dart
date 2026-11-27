import 'package:flutter/material.dart';

import 'loading_state.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? LoadingState(
              size: 18,
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onPrimary,
            )
          : Text(label),
    );
  }
}
