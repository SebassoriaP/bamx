import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bamx/main.dart';

void main() {
  testWidgets('LoginScreen builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(TextField, 'usuario'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'contraseña'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'), findsOneWidget);

    expect(find.widgetWithText(TextButton, 'REGISTRARME'), findsOneWidget);

    expect(find.text('NOKEY'), findsOneWidget);
  });
}