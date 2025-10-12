import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:uuid/uuid.dart';

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
      backgroundColor: const Color.fromRGBO(230, 255, 243, 1),
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
                  color: Color.fromRGBO(24, 35, 156, 1),
                ),
              ),
              const SizedBox(height: 20),
              _buildCardOption("Grid", Icons.grid_view, Colors.teal),
              _buildCardOption("Slider", Icons.tune, Colors.orangeAccent),
              _buildCardOption("Checkbox", Icons.check_box, Colors.purpleAccent),
              _buildCardOption("Card Swipe", Icons.swipe, Colors.cyanAccent),
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
          foregroundColor: Colors.white,
          minimumSize: const Size(260, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          _openCardConfig(type);
        },
        icon: Icon(icon, size: 24),
        label: Text(
          type,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _openCardConfig(String type) async {
    final cardConfig = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CardConfigDialog(
        type: type,
        usedNames: _usedVariableNames,
      ),
    );

    if (cardConfig != null) {
      setState(() {
        _cards.add(cardConfig);
        _usedVariableNames.addAll(
          (cardConfig["variables"] as List<String>?) ?? [],
        );
      });
    }
  }

  void _removeCard(int index) {
    setState(() {
      final vars = _cards[index]["variables"] as List<String>?;
      if (vars != null) _usedVariableNames.removeWhere(vars.contains);
      _cards.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(197, 255, 199, 1),
      appBar: AppBar(
        title: const Text(
          "Form Template Creator",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(24, 35, 156, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(9, 235, 198, 1),
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
                  color: Color.fromRGBO(24, 35, 156, 1),
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Colors.white,
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
                    _buildPreviewCard(_cards[i], i, key: ValueKey(_cards[i]["id"])),
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
                backgroundColor: const Color.fromRGBO(255, 235, 153, 1),
                foregroundColor: const Color.fromRGBO(0, 123, 151, 1),
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

  Widget _buildPreviewCard(Map<String, dynamic> card, int index, {Key? key}) {
    final colorMap = {
      "Grid": Colors.tealAccent.shade100,
      "Slider": Colors.orangeAccent.shade100,
      "Checkbox": Colors.purpleAccent.shade100,
      "Card Swipe": Colors.cyanAccent.shade100,
    };

    return Card(
      key: key,
      elevation: 8,
      color: colorMap[card["type"]] ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          card["type"],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color.fromRGBO(24, 35, 156, 1),
          ),
        ),
        subtitle: Text(
          card["details"],
          style: const TextStyle(fontSize: 16),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _removeCard(index),
        ),
      ),
    );
  }
}

class CardConfigDialog extends StatefulWidget {
  final String type;
  final List<String> usedNames;

  const CardConfigDialog({
    super.key,
    required this.type,
    required this.usedNames,
  });

  @override
  State<CardConfigDialog> createState() => _CardConfigDialogState();
}

class _CardConfigDialogState extends State<CardConfigDialog> {
  final _varControllers = <TextEditingController>[];
  final _minControllers = <TextEditingController>[];
  final _maxControllers = <TextEditingController>[];
  final _questions = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    final variableCount = widget.type == "Grid"
        ? 2
        : widget.type == "Slider"
            ? 1
            : 0;

    for (int i = 0; i < variableCount; i++) {
      _varControllers.add(TextEditingController());
      _minControllers.add(TextEditingController());
      _maxControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isQuestionType =
        widget.type == "Checkbox" || widget.type == "Card Swipe";

    return AlertDialog(
      backgroundColor: const Color.fromRGBO(230, 255, 243, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Configure ${widget.type}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(24, 35, 156, 1),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (!isQuestionType)
              for (int i = 0; i < _varControllers.length; i++)
                _buildVariableField(i),
            if (isQuestionType)
              Column(
                children: [
                  for (int i = 0; i < _questions.length; i++)
                    _buildQuestionField(i),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _questions.add(TextEditingController()));
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Add Question"),
                  )
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _saveCard,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(9, 235, 198, 1),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildVariableField(int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: _varControllers[i],
            decoration: const InputDecoration(labelText: "Variable Name"),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minControllers[i],
                  decoration: const InputDecoration(labelText: "Min"),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _maxControllers[i],
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

  Widget _buildQuestionField(int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: _questions[i],
        decoration: InputDecoration(labelText: "Question ${i + 1}"),
      ),
    );
  }

  void _saveCard() {
    final variables = _varControllers.map((c) => c.text.trim()).toList();
    if (variables.any((v) => widget.usedNames.contains(v))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Variable name already used!")),
      );
      return;
    }

    final details = widget.type == "Grid" || widget.type == "Slider"
        ? variables.map((v) => "$v (${_minControllers[0].text}-${_maxControllers[0].text})").join(", ")
        : _questions.map((q) => q.text).join(", ");

    Navigator.pop(context, {
      "id": uuid.v4(),
      "type": widget.type,
      "variables": variables,
      "details": details,
    });
  }
}