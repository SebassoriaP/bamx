import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:uuid/uuid.dart';
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
              _buildCardOption("Checkbox", Icons.check_box, NokeyColorPalette.purple),
              _buildCardOption("Card Swipe", Icons.swipe, NokeyColorPalette.darkBlue),
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
        // Initialize variables depending on type
        "variables": (type == "Grid")
            ? [
                {"name": "", "min": "", "max": ""},
                {"name": "", "min": "", "max": ""}
                ]
            : (type == "Slider")
                ? [
                    {"name": "", "min": "", "max": ""}
                    ]
                : [],
        // Initialize questions if type needs them
        "questions": (type == "Checkbox" || type == "Card Swipe") ? [""] : [],
        });
    });
    }

    void _removeCard(int index) {
        setState(() {
            final card = _cards[index];

            // Only remove variable names if variables exist and are maps
            final vars = card["variables"];
            if (vars != null && vars is List<Map<String, String>>) {
            for (var v in vars) {
                _usedVariableNames.remove(v["name"]);
            }
            }

            // Optionally, you could also remove used questions if you track them:
            // final questions = card["questions"];
            // if (questions != null && questions is List<String>) { ... }

            _cards.removeAt(index);
        });
  
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
        backgroundColor: NokeyColorPalette.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title input
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

            // Card List (reorderable)
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
                    _buildEditableCard(_cards[i], i, key: ValueKey(_cards[i]["id"])),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add new card button
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
                  icon: const Icon(Icons.delete, color: NokeyColorPalette.mexicanPink),
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
        {"name": "", "min": "", "max": ""},
        {"name": "", "min": "", "max": ""}
    ];

    return Column(
        children: List.generate(card["variables"].length, (i) {
        return _buildVariableInput(card, i);
        }),
    );
    }

  Widget _buildSliderFields(Map<String, dynamic> card) {
    card["variables"] ??= [
        {"name": "", "min": "", "max": ""}
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
            decoration: const InputDecoration(labelText: "Variable Name"),
            onChanged: (val) => variable["name"] = val,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Min"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => variable["min"] = val,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Max"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => variable["max"] = val,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildQuestionFields(Map<String, dynamic> card) {
    card["questions"] ??= [];

    // Always have at least one question to avoid RangeError
    if (card["questions"].isEmpty) card["questions"].add("");

    return Column(
        children: [
        for (int i = 0; i < card["questions"].length; i++)
            Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
                decoration: InputDecoration(labelText: "Question ${i + 1}"),
                onChanged: (val) => card["questions"][i] = val,
            ),
            ),
        TextButton.icon(
            onPressed: () {
            setState(() => card["questions"].add(""));
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Add Question"),
        ),
        ],
    );
  }
}