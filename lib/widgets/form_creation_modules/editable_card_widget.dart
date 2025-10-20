import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/form_creation_modules/variable_input_widget.dart';
import 'package:bamx/widgets/form_creation_modules/question_list_widget.dart';

class EditableCard extends StatelessWidget {
  final Map<String, dynamic> card;
  final VoidCallback onRemove;
  final VoidCallback? onQuestionsUpdated;
  final bool showNameField;

  const EditableCard({
    super.key,
    required this.card,
    required this.onRemove,
    this.onQuestionsUpdated,
    this.showNameField = false,
  });

  @override
  Widget build(BuildContext context) {
    final type = card["type"] as String;
    final colorMap = {
      "Grid": NokeyColorPalette.blue,
      "Slider": NokeyColorPalette.yellow,
      "Checkbox": NokeyColorPalette.purple,
      "Card Swipe": NokeyColorPalette.darkBlue,
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
            // Header row with type and delete button
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
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: card["nameController"],
              decoration: InputDecoration(
                labelText: "$type Name",
                labelStyle: const TextStyle(
                  color: NokeyColorPalette.black,
                  fontWeight: FontWeight.w300,
                ),
                filled: true,
                fillColor: NokeyColorPalette.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NokeyColorPalette.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (type == "Grid")
                    ...List.generate(
                      (card["variables"] as List).length,
                      (i) => VariableInput(
                        controller: card["variables"][i]["nameController"],
                        min: 0,
                        max: 1000000,
                        currentMin: card["variables"][i]["minValue"],
                        currentMax: card["variables"][i]["maxValue"],
                        onMinChanged: (v) =>
                            card["variables"][i]["minValue"] = v,
                        onMaxChanged: (v) =>
                            card["variables"][i]["maxValue"] = v,
                      ),
                    ),
                  if (type == "Slider")
                    VariableInput(
                      controller: card["variables"][0]["nameController"],
                      min: 0,
                      max: 1000000,
                      currentMin: card["variables"][0]["minValue"],
                      currentMax: card["variables"][0]["maxValue"],
                      onMinChanged: (v) => card["variables"][0]["minValue"] = v,
                      onMaxChanged: (v) => card["variables"][0]["maxValue"] = v,
                    ),
                  if (type == "Checkbox" || type == "Card Swipe")
                    QuestionList(
                      questions: card["questions"],
                      addQuestion: () {
                        card["questions"].add({
                          "controller": TextEditingController(),
                        });
                        if (onQuestionsUpdated != null) onQuestionsUpdated!();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
