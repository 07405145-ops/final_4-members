import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation_refresh_observer.dart';
import '../providers/auth_provider.dart';
import '../services/prefs_service.dart';
import '../screens/register_screen.dart';
import '../widgets/organisms/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final result = await auth.login(_email.text.trim(), _pass.text);
    if (!mounted) return;
    if (auth.error == null && result != null) {
      await PrefsService.saveLogin(
        email: result['email']!,
        name: result['name']!,
        uid: result['uid']!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: NavigationLoadingBody(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const _LoginHeader(),
                  const SizedBox(height: 24),
                  LoginForm(
                    formKey: _formKey,
                    emailController: _email,
                    passwordController: _pass,
                    obscurePassword: _obscurePass,
                    onTogglePasswordVisibility: () =>
                        setState(() => _obscurePass = !_obscurePass),
                    error: auth.error,
                    busy: auth.busy,
                    onSubmit: _submit,
                    onRegister: () {
                      auth.clearError();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();
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
