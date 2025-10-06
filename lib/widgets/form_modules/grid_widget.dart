import 'package:flutter/material.dart';

class InteractiveGrid extends StatefulWidget {
  final double width;
  final double height;
  final Function(double x, double y) onChanged;

  const InteractiveGrid({
    super.key,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  @override
  State<InteractiveGrid> createState() => _InteractiveGridState();
}

class _InteractiveGridState extends State<InteractiveGrid> {
  late Offset dotPosition;

  @override
  void initState() {
    super.initState();
    // Temporary placeholder; final size determined in build()
    dotPosition = Offset.zero;
  }

  void _updatePosition(Offset localPos, Size size) {
    // Clamp to actual size
    final dx = localPos.dx.clamp(0.0, size.width);
    final dy = localPos.dy.clamp(0.0, size.height);

    setState(() => dotPosition = Offset(dx, dy));

    final normalizedX = dx / size.width;
    final normalizedY = 1 - (dy / size.height); // invert Y
    widget.onChanged(normalizedX, normalizedY);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = widget.width < constraints.maxWidth
                ? widget.width
                : constraints.maxWidth;
            final height = widget.height;

            // Initialize dot in center if it's zero
            if (dotPosition == Offset.zero) {
              dotPosition = Offset(width / 2, height / 2);
            }

            return GestureDetector(
              onPanStart: (details) => _updatePosition(details.localPosition, Size(width, height)),
              onPanUpdate: (details) => _updatePosition(details.localPosition, Size(width, height)),
              child: SizedBox(
                width: width,
                height: height,
                child: CustomPaint(
                  painter: _GridPainter(dotPosition),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Offset dotPosition;

  _GridPainter(this.dotPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    final Paint dotPaint = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.fill;

    // Draw grid lines
    const gridCount = 10;
    for (int i = 0; i <= gridCount; i++) {
      final dx = size.width * i / gridCount;
      final dy = size.height * i / gridCount;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    // Draw axis lines
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), axisPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), axisPaint);

    // Draw dot
    canvas.drawCircle(dotPosition, 10, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}