import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_4/widgets/organisms/login_form.dart';

void main() {
  testWidgets('shows login validation errors only after submit', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoginForm(
              formKey: formKey,
              emailController: emailController,
              passwordController: passwordController,
              obscurePassword: true,
              onTogglePasswordVisibility: () {},
              error: null,
              busy: false,
              onSubmit: () => formKey.currentState!.validate(),
              onRegister: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Password is required'), findsNothing);

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    emailController.dispose();
    passwordController.dispose();
  });
}
