import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final double height;

  static int _colorIndex = 0; 
  static final List<Color> _colors = [
   NokeyColorPalette.mexicanPink,
  NokeyColorPalette.darkGreen,
  NokeyColorPalette.purple,
  NokeyColorPalette.salmon,
  NokeyColorPalette.darkBlue,
  NokeyColorPalette.green
  ];

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.white,
    this.height = 55,
  });

  Color get _nextColor {
    final color = _colors[_colorIndex % _colors.length];
    _colorIndex++;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final color = _nextColor;

    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: 
          ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            minimumSize: Size(double.infinity, height),
          ),

          child: 
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
        ),
    
      const SizedBox(height: 8),

      const Text(
          '-Tocar para editar-',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: NokeyColorPalette.blue,
          ),
        ),
      ],
    );
  }
}
