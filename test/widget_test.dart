import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bamx/main.dart';

void main() {
  testWidgets('LoginScreen builds without errors', (WidgetTester tester) async {
    // Inicializa la app
    await tester.pumpWidget(const MyApp());

    // Verifica que el LoginScreen se muestre
    expect(find.text('Login / Registro'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
  });
}
