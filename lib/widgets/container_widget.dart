import 'package:flutter/material.dart';

class FlexibleContainer extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final List<Widget>? overlays;


  final Color? color;
  final Gradient? gradient;
  final double borderRadius;

  const FlexibleContainer({
    super.key,
    required this.child,
    this.heightFactor = 0.75,
    this.overlays,
    this.color, 
    this.gradient,
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
        // default color if it's not defined where it is used
        color: color,
        gradient: color == null
            ? (gradient ??
                const LinearGradient(
                  colors: [Color(0xFF00AEEF), Color(0xFF3AB0FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ))
            : null,
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
