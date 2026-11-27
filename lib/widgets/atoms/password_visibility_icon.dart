import 'package:flutter/material.dart';

class PasswordVisibilityIcon extends StatelessWidget {
  const PasswordVisibilityIcon({super.key, required this.visible, required this.onTap});
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
      onPressed: onTap,
    );
  }
}