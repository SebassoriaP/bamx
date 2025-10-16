import 'package:flutter/material.dart';

class QuestionList extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final VoidCallback addQuestion;

  const QuestionList({
    super.key,
    required this.questions,
    required this.addQuestion,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: addQuestion,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Add Question"),
          ),
        ),
      ],
    );
  }
}
