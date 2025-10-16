import 'package:flutter/material.dart';

class NumberPicker extends StatelessWidget {
  final int value;
  final String label;
  final Function(int) onChanged;

  const NumberPicker({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
}
