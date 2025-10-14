import 'package:flutter/material.dart';
import 'package:bamx/widgets/container_widget.dart';

class CardWidget extends StatefulWidget {
  final List<String> questions;
  final String title;
  final void Function(String question, bool answer)? onAnswered;
  final double height;

  const CardWidget({
    super.key,
    required this.questions,
    required this.title,
    this.onAnswered,
    this.height = 400,

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

    if (answered) {
      setState(() {
        currentIndex++;
        cardOffset = Offset.zero;
        rotation = 0;
      });
    } else {
      setState(() {
        cardOffset = Offset.zero;
        rotation = 0;
      });
    }
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
        borderRadius: 20,
        color: const Color.fromARGB(255, 197, 255, 199),
        overlays: [],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                decoration: BoxDecoration(
                  color: Colors.blueAccent, // box color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // text color
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Expanded(
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
                          color: const Color.fromRGBO(255, 140, 142, 1),
                          child: const RotatedBox(
                            quarterTurns: 3,
                            child: Center(
                              child: Text(
                                "NO",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                          color: const Color.fromRGBO(255, 235, 153, 1),
                          child: const RotatedBox(
                            quarterTurns: 1,
                            child: Center(
                              child: Text(
                                "SÍ",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 123, 151, 1),
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
                                  borderRadius: BorderRadius.circular(20),
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
                                          color: Color.fromRGBO(24, 35, 156, 1),
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
                      // Solo mostrar texto cuando ya se terminaron las preguntas
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

              const SizedBox(height: 20),

              // Botón "Anterior"
              ElevatedButton.icon(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Anterior"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
