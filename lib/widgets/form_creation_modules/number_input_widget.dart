import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
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
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant NumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.toString() != _controller.text) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValueFromText() {
    final int? newValue = int.tryParse(_controller.text);
    if (newValue != null) {
      widget.onChanged(newValue);
    } else {
      // reset to current value if invalid
      _controller.text = widget.value.toString();
    }
  }

  void _increment() => widget.onChanged(widget.value + 1);
  void _decrement() => widget.onChanged(widget.value - 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: _decrement),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onEditingComplete: _updateValueFromText,
                      onSubmitted: (_) => _updateValueFromText(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _increment),
            ],
          ),
        ),
      ],
    );
  }
}
