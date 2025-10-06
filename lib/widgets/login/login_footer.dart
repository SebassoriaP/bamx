import 'package:flutter/material.dart';
import 'package:bamx/widgets/button_widget.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback onTestWidgets;

  const LoginFooter({
    super.key,
    required this.onTestWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón de prueba widgets
        ButtonWidget(
            text: "Probar Widgets",
            textColor: Colors.black,
            color: Colors.greenAccent,
            onPressed: onTestWidgets,
        ),
      ],
    );
  }
}