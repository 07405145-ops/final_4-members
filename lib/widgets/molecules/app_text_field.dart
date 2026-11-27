import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.errorBorder,
    this.focusedErrorBorder,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      errorBorder: errorBorder,
      focusedErrorBorder: focusedErrorBorder,
    ),
  );
}
