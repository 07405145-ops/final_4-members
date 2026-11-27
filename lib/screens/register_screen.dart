import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/atoms/loading_state.dart';
import '../widgets/atoms/password_visibility_icon.dart';
import '../widgets/atoms/primary_button.dart';

const _tomatoErrorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFFF6347)),
);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _returningToLogin = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.register(_name.text.trim(), _email.text.trim(), _pass.text);
    if (!mounted) return;
    if (auth.error != null) return;
    setState(() => _returningToLogin = true);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_returningToLogin) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingState(),
              SizedBox(height: 16),
              Text('Account created. Returning to login...'),
            ],
          ),
        ),
      );
    }
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                const _RegisterHeader(),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          errorBorder: _tomatoErrorBorder,
                          focusedErrorBorder: _tomatoErrorBorder,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Full name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          errorBorder: _tomatoErrorBorder,
                          focusedErrorBorder: _tomatoErrorBorder,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final local = v.trim().split('@').first;
                          if (!RegExp(
                            r'^[A-Za-z0-9]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                          ).hasMatch(v.trim())) {
                            return 'Invalid email format (e.g. TestEmail01@gmail.com)';
                          }
                          if (!local.contains(RegExp(r'[A-Z]'))) {
                            return 'Email needs at least 1 uppercase letter';
                          }
                          if (!local.contains(RegExp(r'[0-9]'))) {
                            return 'Email needs at least 1 number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pass,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorBorder: _tomatoErrorBorder,
                          focusedErrorBorder: _tomatoErrorBorder,
                          suffixIcon: PasswordVisibilityIcon(
                            visible: _obscurePass,
                            onTap: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        obscureText: _obscurePass,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(v)) {
                            return 'Password must not contain special characters';
                          }
                          if (!v.contains(RegExp(r'[A-Z]'))) {
                            return 'Password needs at least 1 uppercase letter';
                          }
                          if (!v.contains(RegExp(r'[0-9]'))) {
                            return 'Password needs at least 1 number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          errorBorder: _tomatoErrorBorder,
                          focusedErrorBorder: _tomatoErrorBorder,
                          suffixIcon: PasswordVisibilityIcon(
                            visible: _obscureConfirm,
                            onTap: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        obscureText: _obscureConfirm,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirm password is required';
                          }
                          if (v != _pass.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (auth.error != null) ...[
                        Text(
                          auth.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Create account',
                          loading: auth.busy,
                          onPressed: _submit,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          auth.clearError();
                          Navigator.pop(context);
                        },
                        child: const Text('Have an account? Log in'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.fastfood,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const Text(
          'CanteenGo',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
