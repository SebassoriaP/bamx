import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';

class FooterWidget extends StatelessWidget {
  final VoidCallback onPressed;

  final Color topColor; // color mitad superior
  final Color bottomColor; // color mitad inferior

  const FooterWidget({
    super.key,
    required this.onPressed,
    this.topColor = Colors.transparent,
    this.bottomColor = NokeyColorPalette.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Fondo dividido
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30, // mitad del botón
              color: topColor,
            ),
            Container(
              color: bottomColor,
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              width: double.infinity,
            ),
          ],
        ),

        // Botón circular encima
        Positioned(
          top: 0,
          child: Material(
            shape: const CircleBorder(),
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: NokeyColorPalette.yellow,
                shape: BoxShape.circle,
                border: Border.all(color: NokeyColorPalette.blue, width: 10),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.add,
                    color: NokeyColorPalette.black,
                    size: 44,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
