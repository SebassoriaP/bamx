import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  const MultipleChoiceQuestion({
    super.key,
    required this.question,
    required this.options,
    required this.onChanged,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  final List<String> _selectedOptions = [];

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
      widget.onChanged(_selectedOptions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.options.map((option) {
              final isSelected = _selectedOptions.contains(option);
              return CheckboxListTile(
                title: Text(option),
                value: isSelected,
                onChanged: (_) => _toggleOption(option),
                activeColor: Colors.deepPurple,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
          ],
        ),
      ),
    );
  }
}
