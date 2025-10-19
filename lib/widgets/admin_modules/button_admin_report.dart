import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';
import "package:bamx/widgets/container_widget.dart";

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final double height;
  final String user;
  final Color backgroundColor;

  const ButtonWidget({
    super.key,
    required this.user,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    this.textColor = NokeyColorPalette.white,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            FlexibleContainer(
              color: color,
              heightFactor: 0.13,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: height,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NokeyColorPalette.white,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -18,
              left: 20,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: NokeyColorPalette.blueGrey,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: NokeyColorPalette.blueGrey,
                    width: 2,
                  ),
                ),
                child: Text(
                  user,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: NokeyColorPalette.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        const Text(
          '-Tocar para ver resultados-',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: NokeyColorPalette.blue,
          ),
        ),
        const SizedBox(height: 19),
      ],
    );
  }
}
