import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('BP Monitor'))),
      ),
    );
    expect(find.text('BP Monitor'), findsOneWidget);
  });
}
