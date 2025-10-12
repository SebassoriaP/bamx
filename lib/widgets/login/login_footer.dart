import 'package:flutter/material.dart';
import 'package:bamx/widgets/button_widget.dart';
import 'package:bamx/utils/color_palette.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback onTestWidgets;
  final VoidCallback onTestFormCreation;

  const LoginFooter({
    super.key,
    required this.onTestWidgets,
    required this.onTestFormCreation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón de prueba widgets
        ButtonWidget(
            text: "Try Out Widgets",
            textColor: NokeyColorPalette.black,
            color: NokeyColorPalette.green,
            onPressed: onTestWidgets,
        ),

        const SizedBox(height: 12),

        ButtonWidget(
            text: "Try Out Form Creation",
            textColor: NokeyColorPalette.black,
            color: NokeyColorPalette.salmon,
            onPressed: onTestFormCreation,
        ),
      ],
    );
  }
}