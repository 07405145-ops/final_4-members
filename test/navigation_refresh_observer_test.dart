import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_4/core/navigation_refresh_observer.dart';

void main() {
  testWidgets('shows a loading state for two seconds during navigation', (
    tester,
  ) async {
    final observer = NavigationRefreshObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: NavigationLoadingBody(
              loading: observer.isLoading,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Destination app bar')),
                      body: NavigationLoadingBody(
                        loading: observer.isLoading,
                        child: const Text('Destination'),
                      ),
                    ),
                  ),
                ),
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Navigate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Destination app bar'), findsOneWidget);
    expect(find.text('Destination'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Destination'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
