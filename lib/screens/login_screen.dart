import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/atoms/primary_button.dart';
import '../widgets/molecules/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    final auth = context.read<AuthProvider>();
    if (_isRegister) {
      auth.register(_name.text, _email.text, _pass.text);
    } else {
      auth.login(_email.text, _pass.text);
    }
    // No navigation here: AuthGate switches screens when status changes.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              Icon(Icons.fastfood, size: 72, color: Theme.of(context).colorScheme.primary),
              const Text('CanteenGo',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              if (_isRegister) ...[
                AppTextField(controller: _name, label: 'Full name'),
                const SizedBox(height: 12),
              ],
              AppTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              AppTextField(controller: _pass, label: 'Password', obscure: true),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isRegister ? 'Create account' : 'Log in',
                  loading: auth.busy,
                  onPressed: _submit,
                ),
              ),
              TextButton(
                onPressed: () {
                  auth.clearError();
                  setState(() => _isRegister = !_isRegister);
                },
                child: Text(_isRegister ? 'Have an account? Log in' : 'No account? Register'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
