import 'package:flutter/material.dart';
import 'package:bamx/widgets/container_widget.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/button_widget.dart';

class CardWidget extends StatefulWidget {
  final List<String> questions;
  final String title;
  final void Function(String question, bool answer)? onAnswered;
  final double height;
  final double componentsBorderRadius;

  const CardWidget({
    super.key,
    required this.questions,
    required this.title,
    this.onAnswered,
    this.height = 400,
    this.componentsBorderRadius = 20,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  int currentIndex = 0;
  Offset cardOffset = Offset.zero;
  double rotation = 0;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      cardOffset += details.delta;
      rotation = cardOffset.dx / 100;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool answered = false;

    if (cardOffset.dx > screenWidth * 0.3) {
      widget.onAnswered?.call(widget.questions[currentIndex], true);
      answered = true;
    } else if (cardOffset.dx < -screenWidth * 0.3) {
      widget.onAnswered?.call(widget.questions[currentIndex], false);
      answered = true;
    }

    setState(() {
      if (answered) currentIndex++;
      cardOffset = Offset.zero;
      rotation = 0;
    });
  }

  void _goBack() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool finished = currentIndex >= widget.questions.length;
    final question = !finished
        ? widget.questions[currentIndex]
        : "¡Has respondido todas las preguntas!";

    return SizedBox(
      height: widget.height,
      child: FlexibleContainer(
        heightFactor: 1,
        borderRadius: widget.componentsBorderRadius,
        color: NokeyColorPalette.lightGreen,
        overlays: [],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: NokeyColorPalette.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NokeyColorPalette.white,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              // Question area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: NokeyColorPalette.white,
                    borderRadius: BorderRadius.circular(
                      widget.componentsBorderRadius,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!finished) ...[
                        // Left side-bar (NO)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 50,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 140, 142, 1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  widget.componentsBorderRadius,
                                ),
                                bottomLeft: Radius.circular(
                                  widget.componentsBorderRadius,
                                ),
                              ),
                            ),
                            child: const RotatedBox(
                              quarterTurns: 3,
                              child: Center(
                                child: Text(
                                  "NO",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: NokeyColorPalette.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Right side-bar (SÍ)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 50,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: NokeyColorPalette.lightYellow,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(
                                  widget.componentsBorderRadius,
                                ),
                                bottomRight: Radius.circular(
                                  widget.componentsBorderRadius,
                                ),
                              ),
                            ),
                            child: const RotatedBox(
                              quarterTurns: 1,
                              child: Center(
                                child: Text(
                                  "SÍ",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: NokeyColorPalette.darkGreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Card
                        Center(
                          child: GestureDetector(
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: Transform.translate(
                              offset: cardOffset,
                              child: Transform.rotate(
                                angle: rotation * 0.2,
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      widget.componentsBorderRadius,
                                    ),
                                  ),
                                  color: const Color.fromRGBO(9, 235, 198, 1),
                                  child: SizedBox(
                                    width: 180,
                                    height: double.infinity,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Text(
                                          question,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(
                                              24,
                                              35,
                                              156,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // End message
                        Center(
                          child: Text(
                            question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(24, 35, 156, 1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ButtonWidget(
                text: "<- Anterior",
                color: NokeyColorPalette.purple,
                onPressed: _goBack,
                textColor: NokeyColorPalette.white,
                height: 55,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
