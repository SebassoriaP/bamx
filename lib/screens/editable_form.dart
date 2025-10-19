import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:reorderables/reorderables.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/form_creation_modules/editable_card_widget.dart';
import 'package:bamx/widgets/form_creation_modules/card_option_widget.dart';

final uuid = Uuid();

class FormEditorScreen extends StatefulWidget {
  final String formId;

  const FormEditorScreen({super.key, required this.formId});

  @override
  State<FormEditorScreen> createState() => _FormEditorScreenState();
}

class _FormEditorScreenState extends State<FormEditorScreen> {
  final TextEditingController _formTitleController = TextEditingController();
  final List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    final doc = await FirebaseFirestore.instance
        .collection('forms')
        .doc(widget.formId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    _formTitleController.text = data['form_name'] ?? '';

    final questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);

    _cards.clear();
    for (var q in questions) {
      String type = q['type'] ?? '';
      List<Map<String, dynamic>> variables = [];
      List<Map<String, dynamic>> questionsList = [];

      final metadata = q['metadata'];

      if ((type == 'Grid' || type == 'Slider') && metadata is List) {
        variables = metadata.map<Map<String, dynamic>>((v) {
          return {
            'nameController': TextEditingController(text: v['name'] ?? ''),
            'minValue': int.tryParse(v['min'].toString()) ?? 0,
            'maxValue': int.tryParse(v['max'].toString()) ?? 10,
          };
        }).toList();
      } else if ((type == 'Checkbox' || type == 'Card Swipe') && metadata is List) {
        questionsList = metadata.map<Map<String, dynamic>>((v) {
          if (v is String) {
            return {'controller': TextEditingController(text: v)};
          } else if (v is Map) {
            return {'controller': TextEditingController(text: v['name'] ?? '')};
          } else {
            return {'controller': TextEditingController(text: '')};
          }
        }).toList();
      }

      _cards.add({
        'id': q['id'] ?? uuid.v4(),
        'type': type,
        'nameController': TextEditingController(text: q['name'] ?? ''),
        'variables': variables,
        'questions': questionsList,
      });
    }

    setState(() {});
  }

  Future<void> _saveForm() async {
    if (_formTitleController.text.isEmpty) return;

    final questionsToSave = _cards.map((card) {
      dynamic metadata;
      if (card['type'] == 'Slider' || card['type'] == 'Grid') {
        metadata = (card['variables'] as List).map((v) {
          return {
            'name': v['nameController']?.text ?? '',
            'min': v['minValue'].toString(),
            'max': v['maxValue'].toString(),
          };
        }).toList();
      } else if (card['type'] == 'Checkbox' || card['type'] == 'Card Swipe') {
        metadata = (card['questions'] as List).map((q) => q['controller'].text).toList();
      } else {
        metadata = {};
      }

      return {
        'id': card['id'],
        'type': card['type'],
        'name': card['nameController']?.text ?? '',
        'metadata': metadata,
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('forms')
        .doc(widget.formId)
        .update({
      'form_name': _formTitleController.text,
      'questions': questionsToSave,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Formulario actualizado correctamente!")),
    );
  }

  void _removeCard(int index) {
    final card = _cards[index];

    card['nameController']?.dispose();
    if (card['variables'] != null) {
      for (var v in List<Map<String, dynamic>>.from(card['variables'])) {
        v['nameController']?.dispose();
      }
    }
    if (card['questions'] != null) {
      for (var q in List<Map<String, dynamic>>.from(card['questions'])) {
        q['controller']?.dispose();
      }
    }

    setState(() {
      _cards.removeAt(index);
    });
  }

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
        "nameController": TextEditingController(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        iconTheme: IconThemeData(
          color: NokeyColorPalette.white, // Arrow back - color
        ),
        
        title: Text(
          "Editar Formulario", 
          style: TextStyle(
            color:NokeyColorPalette.white,
          ),
        ),

        backgroundColor: NokeyColorPalette.blue,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              color: NokeyColorPalette.white,
              ),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _formTitleController,
              decoration: const InputDecoration(
                labelText: "Título del formulario",
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
                    key: ValueKey(_cards[i]['id']),
                    card: _cards[i],
                    onRemove: () => _removeCard(i),
                    onQuestionsUpdated: () => setState(() {}),
                    showNameField: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addCardDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Agregar nueva tarjeta"),
              style: ElevatedButton.styleFrom(
                backgroundColor: NokeyColorPalette.blue,
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
