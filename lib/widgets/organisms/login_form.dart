import 'package:flutter/material.dart';

import '../atoms/password_visibility_icon.dart';
import '../atoms/primary_button.dart';
import '../molecules/app_text_field.dart';

const _tomatoErrorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFFF6347)),
);

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.error,
    required this.busy,
    required this.onSubmit,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final String? error;
  final bool busy;
  final VoidCallback onSubmit;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppTextField(
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            errorBorder: _tomatoErrorBorder,
            focusedErrorBorder: _tomatoErrorBorder,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: passwordController,
            label: 'Password',
            obscure: obscurePassword,
            errorBorder: _tomatoErrorBorder,
            focusedErrorBorder: _tomatoErrorBorder,
            suffixIcon: PasswordVisibilityIcon(
              visible: obscurePassword,
              onTap: onTogglePasswordVisibility,
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Password is required'
                : null,
          ),
          const SizedBox(height: 20),
          if (error != null) ...[
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Log in',
              loading: busy,
              onPressed: onSubmit,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRegister,
            child: const Text('No account? Register'),
          ),
        ],
      ),
    );
  }
}
