import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_rcs_app_v1/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(ChatApp());

    expect(find.text('Chat Demo'), findsOneWidget);
  });
}