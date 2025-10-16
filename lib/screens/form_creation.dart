import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:reorderables/reorderables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bamx/utils/color_palette.dart';

import 'package:bamx/widgets/form_creation_modules/card_option_widget.dart';
import 'package:bamx/widgets/form_creation_modules/editable_card_widget.dart';

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
      builder: (_) => Padding(
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
            CardOptionButton(
              type: "Grid",
              icon: Icons.grid_view,
              color: NokeyColorPalette.blue,
              onTap: () {
                Navigator.pop(context);
                _addInlineCard("Grid");
              },
            ),
            CardOptionButton(
              type: "Slider",
              icon: Icons.tune,
              color: NokeyColorPalette.yellow,
              onTap: () {
                Navigator.pop(context);
                _addInlineCard("Slider");
              },
            ),
            CardOptionButton(
              type: "Checkbox",
              icon: Icons.check_box,
              color: NokeyColorPalette.purple,
              onTap: () {
                Navigator.pop(context);
                _addInlineCard("Checkbox");
              },
            ),
            CardOptionButton(
              type: "Card Swipe",
              icon: Icons.swipe,
              color: NokeyColorPalette.darkBlue,
              onTap: () {
                Navigator.pop(context);
                _addInlineCard("Card Swipe");
              },
            ),
          ],
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingresa un nombre.")),
      );
      return;
    }
    if (_cards.isEmpty) {
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Formulario guardado correctamente!")),
      );
      if (!mounted) return;
      setState(() {
        _formTitleController.clear();
        _cards.clear();
      });
    } catch (e) {
      if (!mounted) return;
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
                  (i) => EditableCard(
                    key: ValueKey(_cards[i]["id"]),
                    card: _cards[i],
                    onRemove: () => _removeCard(i),
                    onQuestionsUpdated: () => setState(() {}),
                  ),
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
}
