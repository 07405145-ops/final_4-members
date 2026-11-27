import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_4/widgets/atoms/loading_state.dart';

void main() {
  testWidgets('shows refresh after two seconds and restarts the delay',
      (tester) async {
    var refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LoadingState(onRefresh: () => refreshCount++),
          ),
        ),
      ),
    );

    expect(find.text('Refresh'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1999));
    expect(find.text('Refresh'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Refresh'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();
    expect(refreshCount, 1);
    expect(find.text('Refresh'), findsNothing);
  });
}
