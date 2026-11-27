import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_theme.dart';
import 'services/prefs_service.dart';
import 'widgets/atoms/loading_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  Future<void>? _firebaseInitialization;
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    await PrefsService.init();
    if (Firebase.apps.isNotEmpty) return;

    final pending = _firebaseInitialization;
    if (pending != null) return pending;

    final attempt = Firebase.initializeApp();
    _firebaseInitialization = attempt;
    try {
      await attempt;
    } finally {
      if (identical(_firebaseInitialization, attempt)) {
        _firebaseInitialization = null;
      }
    }
  }

  void _refresh() {
    setState(() => _initialization = _initialize());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return const CanteenGoApp();
        }

        final content = snapshot.hasError
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unable to start the app: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.light.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  LoadingState(onRefresh: _refresh),
                ],
              )
            : LoadingState(onRefresh: _refresh);

        return MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: Center(child: content)),
        );
      },
    );
  }
}
