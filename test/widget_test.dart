// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_model_vram_calculator/main.dart';

void main() {
  testWidgets('Calculator screen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VramCalculatorApp());

    // Verify that the main title is rendered.
    expect(find.text('Advanced LLM VRAM Calculator'), findsOneWidget);

    // Verify that the calculate button is present.
    expect(find.widgetWithText(ElevatedButton, 'Calculate VRAM'), findsOneWidget);
  });
}
