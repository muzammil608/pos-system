import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_system_app/main.dart';

void main() {
  testWidgets('POS app loads login screen', (WidgetTester tester) async {
    // Build the POS app
    await tester.pumpWidget(PosApp());

    // Verify Login screen UI
    expect(find.text('POS Login'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    // Verify TextField exists
    expect(find.byType(TextField), findsOneWidget);
  });
}
