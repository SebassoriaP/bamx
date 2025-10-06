import 'package:flutter/material.dart';

class BlueContainer extends StatelessWidget {
  final Widget child;
  final double heightFactor;
  final List<Widget>? overlays;

  const BlueContainer({
    super.key,
    required this.child,
    this.heightFactor = 0.75,
    this.overlays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00AEEF), Color(0xFF3AB0FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
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