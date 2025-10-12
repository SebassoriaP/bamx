import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final Color textColor;
  final double height;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    this.textColor = NokeyColorPalette.white,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size(double.infinity, height),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}