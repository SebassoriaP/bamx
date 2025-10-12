import 'package:flutter/material.dart';
import 'package:bamx/widgets/form_modules/grid_widget.dart';
import 'package:bamx/widgets/form_modules/slider_widget.dart';
import 'package:bamx/widgets/form_modules/card_widget.dart';
import 'package:bamx/widgets/form_modules/checkbox_widget.dart';
import 'package:bamx/widgets/form_modules/textbox_widget.dart';

class TestGridScreen extends StatefulWidget {
  const TestGridScreen({super.key});

  @override
  State<TestGridScreen> createState() => _TestGridScreenState();
}

class _TestGridScreenState extends State<TestGridScreen> {
  double _sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Grid + Slider + Cards'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🟦 Interactive Grid
              const Text(
                '🟦 Interfaz de cuadrícula interactiva',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: InteractiveGrid(
                  width: 300,
                  height: 300,
                  onChanged: (x, y) {
                    debugPrint('Selected values → X: $x, Y: $y');
                  },
                ),
              ),
              const SizedBox(height: 40),

              CustomSlider(
                question: "¿Qué alimentos te gustan?",
                min: 0,
                max: 100,
                initialValue: _sliderValue,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                  debugPrint('Nuevo valor del slider: $value');
                },
              ),
              const SizedBox(height: 50),

              // Swipe Cards
              SizedBox(
                height: 400,
                child: CardWidget(
                  title: "Preguntas tipo Tinder (Sí / No)",
                  questions: const [
                    "¿Te gusta la pizza?",
                    "¿Has viajado al extranjero?",
                    "¿Te consideras una persona puntual?",
                    "¿Usas Flutter para tus proyectos?",
                  ],
                  onAnswered: (question, answer) {
                    debugPrint(
                      'Pregunta: "$question" → ${answer ? "Sí" : "No"}',
                    );
                  },
                ),
              ),

              const SizedBox(height: 50),

              // MultipleChoiceQuestion
              MultipleChoiceQuestion(
                question: "¿Qué alimentos te gustan?",
                options: ["Frutas", "Verduras", "Carnes", "Lácteos"],
                onChanged: (selected) {
                  debugPrint("Seleccionados: $selected");
                },
              ),

              const SizedBox(height: 50),

              // 📝 Caja de texto
              CustomTextField(
                label: "Nombre completo",
                hint: "Ingresa tu nombre",
                onChanged: (value) {
                  debugPrint("Texto ingresado: $value");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
