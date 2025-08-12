import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gramconnect/main.dart';

void main() {
  testWidgets('App launches and shows login or home screen', (WidgetTester tester) async {
    // Build and launch your app
    await tester.pumpWidget(const MyApp()); // or GramConnectApp() if renamed

    // Allow animations and routing to settle
    await tester.pumpAndSettle();

    // Expect at least one key widget — like login or home screen — to appear
    expect(find.text('Login'), findsOneWidget); // or any widget that exists on your first screen
  });
}