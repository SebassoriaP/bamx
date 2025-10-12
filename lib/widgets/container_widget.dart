import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';

class FlexibleContainer extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final List<Widget>? overlays;


  final Color? color;
  final double borderRadius;

  const FlexibleContainer({
    super.key,
    required this.child,
    this.heightFactor = 0.75,
    this.overlays,
    this.color, 
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: color ?? NokeyColorPalette.blue,
      ),
      child: Stack(
        children: [
          Center(child: child),
          if (overlays != null) ...overlays!,
        ],
      ),
    );
  }
}
