import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'screens/login_screen.dart';
import 'screens/staff_home.dart';
import 'screens/student_home.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'widgets/atoms/loading_state.dart';

class CanteenGoApp extends StatelessWidget {
  const CanteenGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(
          create: (c) => AuthProvider(c.read<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: 'CanteenGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fs = context.read<FirestoreService>();

    switch (auth.status) {
      case AuthStatus.loading:
        return Scaffold(
          body: Center(child: LoadingState(onRefresh: auth.refresh)),
        );
      case AuthStatus.signedOut:
        return const LoginScreen();
      case AuthStatus.student:
        if (auth.user == null) {
          return Scaffold(
            body: Center(child: LoadingState(onRefresh: auth.refresh)),
          );
        }
        return MultiProvider(
          key: ValueKey('student-${auth.user!.uid}'),
          providers: [
            ChangeNotifierProvider(create: (_) => MenuProvider(fs)),
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(
              create: (_) => OrderProvider.student(
                fs,
                auth.user!.uid,
                auth.user!.email ?? '',
              ),
            ),
          ],
          child: const StudentHome(),
        );
      case AuthStatus.staff:
        if (auth.user == null) {
          return Scaffold(
            body: Center(child: LoadingState(onRefresh: auth.refresh)),
          );
        }
        return MultiProvider(
          key: ValueKey('staff-${auth.user!.uid}'),
          providers: [
            ChangeNotifierProvider(create: (_) => MenuProvider(fs)),
            ChangeNotifierProvider(create: (_) => OrderProvider.staff(fs)),
          ],
          child: const StaffHome(),
        );
    }
  }
}
