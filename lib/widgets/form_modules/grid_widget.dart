import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';

class InteractiveGrid extends StatefulWidget {
  final double width;
  final double height;
  final String title;
  final String xLabel;
  final String yLabel;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final Function(double x, double y) onChanged;

  const InteractiveGrid({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.xLabel,
    required this.yLabel,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
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
    dotPosition = Offset.zero;
  }

  void _updatePosition(Offset localPos, Size size) {
    final dx = localPos.dx.clamp(0.0, size.width);
    final dy = localPos.dy.clamp(0.0, size.height);

    setState(() => dotPosition = Offset(dx, dy));

    // ✅ X increases to the right
    final normalizedX =
        widget.xMin + (dx / size.width) * (widget.xMax - widget.xMin);

    // ✅ Y increases upward (inverted visually)
    final normalizedY =
        widget.yMax - (dy / size.height) * (widget.yMax - widget.yMin);

    widget.onChanged(normalizedX, normalizedY);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width + 50,
      child: Container(
        padding: const EdgeInsets.all(16).copyWith(bottom: 35),
        width: widget.width + 40,
        decoration: BoxDecoration(
          color: NokeyColorPalette.lightBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: NokeyColorPalette.blue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: NokeyColorPalette.white,
                  ),
                ),
              ),
            ),

            // Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = widget.width;
                final height = widget.height;
                if (dotPosition == Offset.zero) {
                  dotPosition = Offset(width / 2, height / 2);
                }

                return GestureDetector(
                  onPanStart: (d) =>
                      _updatePosition(d.localPosition, Size(width, height)),
                  onPanUpdate: (d) =>
                      _updatePosition(d.localPosition, Size(width, height)),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: width,
                        height: height,
                        child: CustomPaint(
                          painter: _GridPainter(
                            dotPosition,
                            xLabel: widget.xLabel,
                            yLabel: widget.yLabel,
                          ),
                        ),
                      ),

                      // Dynamic label
                      Builder(
                        builder: (_) {
                          const labelPadding = 20.0;
                          const labelWidth = 100.0;
                          const labelHeight = 32.0;

                          double left = dotPosition.dx + labelPadding;
                          double top = dotPosition.dy - labelHeight / 2;

                          if (left + labelWidth > width) {
                            left = dotPosition.dx - labelWidth - labelPadding;
                          }

                          if (top < 0){
                            top = 0;
                          }

                          if (top + labelHeight > height){
                            top = height - labelHeight;
                          }

                          return Positioned(
                            left: left,
                            top: top,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.yLabel} = ${_mapToValue(dotPosition.dy, height, widget.yMin, widget.yMax, isY: true).toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: NokeyColorPalette.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${widget.xLabel} = ${_mapToValue(dotPosition.dx, width, widget.xMin, widget.xMax, isY: false).toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: NokeyColorPalette.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _mapToValue(
    double position,
    double total,
    double minValue,
    double maxValue, {
    required bool isY,
  }) {
    // ✅ X: increase to the right
    // ✅ Y: increase upward
    if (isY) {
      return maxValue - (position / total) * (maxValue - minValue);
    }
    return minValue + (position / total) * (maxValue - minValue);
  }
}

class _GridPainter extends CustomPainter {
  final Offset dotPosition;
  final String xLabel;
  final String yLabel;

  _GridPainter(this.dotPosition, {required this.xLabel, required this.yLabel});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = NokeyColorPalette.blueGrey
      ..strokeWidth = 1;

    const gridCount = 10;

    for (int i = 0; i <= gridCount; i++) {
      final dx = size.width * i / gridCount;
      final dy = size.height * i / gridCount;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final axisPaint = Paint()
      ..color = NokeyColorPalette.blue
      ..strokeWidth = 3;

    // X and Y axes
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    void drawText(String text, Offset offset, {Color color = NokeyColorPalette.blue}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, offset);
    }

    drawText(xLabel, Offset(size.width / 2 - 20, size.height + 8));

    final yLabelChars = yLabel.split('');
    final double startY = size.height / 2 - (yLabelChars.length * 8);
    for (int i = 0; i < yLabelChars.length; i++) {
      drawText(
        yLabelChars[i],
        Offset(-20, startY + i * 16),
        color: NokeyColorPalette.blue,
      );
    }

    // Dot
    final dotPaint = Paint()..color = NokeyColorPalette.purple;
    canvas.drawCircle(dotPosition, 12, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => true;
}
