import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/utils/color_palette.dart';

final uuid = Uuid();

class FormCreationScreen extends StatefulWidget {
  const FormCreationScreen({super.key});

  @override
  State<FormCreationScreen> createState() => _FormCreationScreenState();
}

class _FormCreationScreenState extends State<FormCreationScreen> {
  final TextEditingController _formTitleController = TextEditingController();
  final List<Map<String, dynamic>> _cards = [];

  void _addCardDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: NokeyColorPalette.blueGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text(
                "Add a new component",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: NokeyColorPalette.darkBlue,
                ),
              ),
              const SizedBox(height: 20),
              _buildCardOption("Grid", Icons.grid_view, NokeyColorPalette.blue),
              _buildCardOption("Slider", Icons.tune, NokeyColorPalette.yellow),
              _buildCardOption(
                "Checkbox",
                Icons.check_box,
                NokeyColorPalette.purple,
              ),
              _buildCardOption(
                "Card Swipe",
                Icons.swipe,
                NokeyColorPalette.darkBlue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardOption(String type, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: NokeyColorPalette.white,
          minimumSize: const Size(260, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          _addInlineCard(type);
        },
        icon: Icon(icon, size: 24),
        label: Text(
          type,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _addInlineCard(String type) {
    setState(() {
      _cards.add({
        "id": uuid.v4(),
        "type": type,
        "variables": (type == "Grid")
            ? List.generate(
                2,
                (_) => {
                  "nameController": TextEditingController(),
                  "minValue": 0,
                  "maxValue": 10,
                },
              )
            : (type == "Slider")
            ? [
                {
                  "nameController": TextEditingController(),
                  "minValue": 0,
                  "maxValue": 10,
                },
              ]
            : [],
        "questions": (type == "Checkbox" || type == "Card Swipe")
            ? [
                {"controller": TextEditingController()},
              ]
            : [],
      });
    });
  }

  void _removeCard(int index) {
    final card = _cards[index];

    // Dispose controllers
    if (card["variables"] != null) {
      for (var v in List<Map<String, dynamic>>.from(card["variables"])) {
        v["nameController"]?.dispose();
      }
    }
    if (card["questions"] != null) {
      for (var q in List<Map<String, dynamic>>.from(card["questions"])) {
        q["controller"]?.dispose();
      }
    }

    setState(() {
      _cards.removeAt(index);
    });
  }

  Future<void> _saveFormToFirestore() async {
    final formName = _formTitleController.text.trim();
    if (formName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingresa un nombre.")),
      );
      return;
    }
    if (_cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agrega al menos un componente antes de guardar."),
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> questions = _cards.map((card) {
      dynamic metadata;
      if (card["type"] == "Grid" || card["type"] == "Slider") {
        metadata = (card["variables"] as List)
            .map(
              (v) => {
                "name": v["nameController"].text,
                "min": v["minValue"].toString(),
                "max": v["maxValue"].toString(),
              },
            )
            .toList();
      } else if (card["type"] == "Checkbox" || card["type"] == "Card Swipe") {
        metadata = (card["questions"] as List)
            .map((q) => q["controller"].text)
            .toList();
      } else {
        metadata = {};
      }
      return {"type": card["type"], "metadata": metadata, "id": card["id"]};
    }).toList();

    final formData = {
      "admin_id": "/admins/ynTdLLPTJ6uThegM35jX",
      "created": FieldValue.serverTimestamp(),
      "form_name": formName,
      "questions": questions,
    };

    try {
      await FirebaseFirestore.instance.collection("forms").add(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Formulario guardado correctamente!")),
      );
      setState(() {
        _formTitleController.clear();
        _cards.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NokeyColorPalette.white,
      appBar: AppBar(
        title: const Text(
          "Form Template Creator",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: NokeyColorPalette.white,
          ),
        ),
        backgroundColor: NokeyColorPalette.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _formTitleController,
              decoration: InputDecoration(
                labelText: "Form Title",
                labelStyle: const TextStyle(
                  color: NokeyColorPalette.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: NokeyColorPalette.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableColumn(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    final card = _cards.removeAt(oldIndex);
                    _cards.insert(newIndex, card);
                  });
                },
                children: List.generate(
                  _cards.length,
                  (i) => _buildEditableCard(_cards[i], i),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addCardDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Add New Card"),
              style: ElevatedButton.styleFrom(
                backgroundColor: NokeyColorPalette.yellow,
                foregroundColor: NokeyColorPalette.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveFormToFirestore,
              icon: const Icon(Icons.save_alt),
              label: const Text("Guardar Formulario"),
              style: ElevatedButton.styleFrom(
                backgroundColor: NokeyColorPalette.darkBlue,
                foregroundColor: NokeyColorPalette.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCard(Map<String, dynamic> card, int index) {
    final type = card["type"] as String;
    final colorMap = {
      "Grid": NokeyColorPalette.blue,
      "Slider": NokeyColorPalette.yellow,
      "Checkbox": NokeyColorPalette.purple,
      "Card Swipe": NokeyColorPalette.blueGrey,
    };

    return Card(
      key: ValueKey(card["id"]),
      elevation: 6,
      color: colorMap[type],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: NokeyColorPalette.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: NokeyColorPalette.mexicanPink,
                  ),
                  onPressed: () => _removeCard(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NokeyColorPalette.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (type == "Grid") _buildGridFields(card),
                  if (type == "Slider") _buildSliderFields(card),
                  if (type == "Checkbox" || type == "Card Swipe")
                    _buildQuestionFields(card),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridFields(Map<String, dynamic> card) {
    final variables = card["variables"] as List<dynamic>;
    return Column(
      children: List.generate(
        variables.length,
        (i) => _buildVariableInput(variables[i] as Map<String, dynamic>),
      ),
    );
  }

  Widget _buildSliderFields(Map<String, dynamic> card) {
    final variable =
        (card["variables"] as List<dynamic>)[0] as Map<String, dynamic>;
    return _buildVariableInput(variable);
  }

  Widget _buildVariableInput(Map<String, dynamic> variable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          TextField(
            controller: variable["nameController"],
            decoration: const InputDecoration(
              labelText: "Variable Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildNumberPicker(
                  value: variable["minValue"],
                  onChanged: (val) =>
                      setState(() => variable["minValue"] = val),
                  label: "Min",
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildNumberPicker(
                  value: variable["maxValue"],
                  onChanged: (val) =>
                      setState(() => variable["maxValue"] = val),
                  label: "Max",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPicker({
    required int value,
    required Function(int) onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => onChanged(value - 1),
              ),
              Expanded(
                child: Center(
                  child: Text("$value", style: const TextStyle(fontSize: 16)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionFields(Map<String, dynamic> card) {
    final questions = card["questions"] as List<dynamic>;
    return Column(
      children: [
        for (int i = 0; i < questions.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              controller: questions[i]["controller"],
              decoration: InputDecoration(
                labelText: "Question ${i + 1}",
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                questions.add({"controller": TextEditingController()});
              });
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Add Question"),
          ),
        ),
      ],
    );
  }
}
