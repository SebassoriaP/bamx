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
  final List<String> _usedVariableNames = [];

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
            ? [
                {
                  "name": "",
                  "min": "",
                  "max": "",
                  "nameController": TextEditingController(),
                  "minController": TextEditingController(),
                  "maxController": TextEditingController(),
                },
                {
                  "name": "",
                  "min": "",
                  "max": "",
                  "nameController": TextEditingController(),
                  "minController": TextEditingController(),
                  "maxController": TextEditingController(),
                },
              ]
            : (type == "Slider")
                ? [
                    {
                      "name": "",
                      "min": "",
                      "max": "",
                      "nameController": TextEditingController(),
                      "minController": TextEditingController(),
                      "maxController": TextEditingController(),
                    }
                  ]
                : [],
        "questions": (type == "Checkbox" || type == "Card Swipe")
            ? [
                {"text": "", "controller": TextEditingController()}
              ]
            : [],
      });
    });
  }

  void _removeCard(int index) {
    final card = _cards[index];

    // Dispose controllers for cleanup
    if (card["variables"] != null) {
      for (var v in card["variables"]) {
        v["nameController"]?.dispose();
        v["minController"]?.dispose();
        v["maxController"]?.dispose();
      }
    }
    if (card["questions"] != null) {
      for (var q in card["questions"]) {
        q["controller"]?.dispose();
      }
    }

    setState(() {
      final vars = card["variables"];
      if (vars != null && vars is List<Map<String, dynamic>>) {
        for (var v in vars) {
          _usedVariableNames.remove(v["name"]);
        }
      }
      _cards.removeAt(index);
    });
  }

  Future<void> _saveFormToFirestore() async {
    final formName = _formTitleController.text.trim();

    if (formName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor, ingresa un nombre para el formulario.")),
      );
      return;
    }

    if (_cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Agrega al menos un componente antes de guardar.")),
      );
      return;
    }

    final List<Map<String, dynamic>> questions = _cards.map((card) {
      dynamic metadata;

      if (card["type"] == "Grid" || card["type"] == "Slider") {
        metadata = card["variables"]
            .map((v) => {
                  "name": v["nameController"].text,
                  "min": v["minController"].text,
                  "max": v["maxController"].text,
                })
            .toList();
      } else if (card["type"] == "Checkbox" || card["type"] == "Card Swipe") {
        metadata = card["questions"]
            .map((q) => q["controller"].text)
            .toList();
      } else {
        metadata = {};
      }

      return {
        "type": card["type"],
        "metadata": metadata,
        "name": card["id"],
      };
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
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
        elevation: 0,
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
                children: [
                  for (int i = 0; i < _cards.length; i++)
                    _buildEditableCard(
                      _cards[i],
                      i,
                      key: ValueKey(_cards[i]["id"]),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add Card Button
            ElevatedButton.icon(
              onPressed: _addCardDialog,
              icon: const Icon(Icons.add_circle_outline, size: 26),
              label: const Text(
                "Add New Card",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: NokeyColorPalette.yellow,
                foregroundColor: NokeyColorPalette.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
              ),
            ),

            const SizedBox(height: 10),

            // Save Form Button
            ElevatedButton.icon(
              onPressed: _saveFormToFirestore,
              icon: const Icon(Icons.save_alt, size: 26),
              label: const Text(
                "Guardar Formulario",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: NokeyColorPalette.darkBlue,
                foregroundColor: NokeyColorPalette.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCard(Map<String, dynamic> card, int index, {Key? key}) {
    final type = card["type"];
    final colorMap = {
      "Grid": NokeyColorPalette.blue,
      "Slider": NokeyColorPalette.yellow,
      "Checkbox": NokeyColorPalette.purple,
      "Card Swipe": NokeyColorPalette.blueGrey,
    };

    return Card(
      key: key,
      elevation: 8,
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
                    fontSize: 20,
                    color: NokeyColorPalette.black,
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
            const SizedBox(height: 10),
            if (type == "Grid") _buildGridFields(card),
            if (type == "Slider") _buildSliderFields(card),
            if (type == "Checkbox" || type == "Card Swipe")
              _buildQuestionFields(card),
          ],
        ),
      ),
    );
  }

  Widget _buildGridFields(Map<String, dynamic> card) {
    card["variables"] ??= [
      {
        "nameController": TextEditingController(),
        "minController": TextEditingController(),
        "maxController": TextEditingController(),
      },
      {
        "nameController": TextEditingController(),
        "minController": TextEditingController(),
        "maxController": TextEditingController(),
      },
    ];

    return Column(
      children: List.generate(card["variables"].length, (i) {
        return _buildVariableInput(card, i);
      }),
    );
  }

  Widget _buildSliderFields(Map<String, dynamic> card) {
    card["variables"] ??= [
      {
        "nameController": TextEditingController(),
        "minController": TextEditingController(),
        "maxController": TextEditingController(),
      },
    ];
    return _buildVariableInput(card, 0);
  }

  Widget _buildVariableInput(Map<String, dynamic> card, int i) {
    final variable = card["variables"][i];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          TextField(
            controller: variable["nameController"],
            decoration: const InputDecoration(labelText: "Variable Name"),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: variable["minController"],
                  decoration: const InputDecoration(labelText: "Min"),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: variable["maxController"],
                  decoration: const InputDecoration(labelText: "Max"),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionFields(Map<String, dynamic> card) {
    card["questions"] ??= [
      {"text": "", "controller": TextEditingController()}
    ];

    return Column(
      children: [
        for (int i = 0; i < card["questions"].length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              controller: card["questions"][i]["controller"],
              decoration: InputDecoration(labelText: "Question ${i + 1}"),
            ),
          ),
        TextButton.icon(
          onPressed: () {
            setState(() => card["questions"]
                .add({"text": "", "controller": TextEditingController()}));
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Add Question"),
        ),
      ],
    );
  }
}