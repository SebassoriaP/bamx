import 'package:flutter/material.dart';

class VariableInput extends StatefulWidget {
  final TextEditingController controller;
  final int min;
  final int max;
  final int currentMin;
  final int currentMax;
  final Function(int) onMinChanged;
  final Function(int) onMaxChanged;

  const VariableInput({
    super.key,
    required this.controller,
    required this.min,
    required this.max,
    required this.currentMin,
    required this.currentMax,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  _VariableInputState createState() => _VariableInputState();
}

class _VariableInputState extends State<VariableInput> {
  late int minValue;
  late int maxValue;

  @override
  void initState() {
    super.initState();
    minValue = widget.currentMin;
    maxValue = widget.currentMax;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          TextField(
            controller: widget.controller,
            decoration: const InputDecoration(
              labelText: "Variable Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: minValue > widget.min
                          ? () {
                              setState(() {
                                minValue--;
                              });
                              widget.onMinChanged(minValue);
                            }
                          : null,
                    ),
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.center,
                        readOnly: true,
                        controller:
                            TextEditingController(text: minValue.toString()),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: minValue < maxValue && minValue < widget.max
                          ? () {
                              setState(() {
                                minValue++;
                              });
                              widget.onMinChanged(minValue);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: maxValue > minValue && maxValue > widget.min
                          ? () {
                              setState(() {
                                maxValue--;
                              });
                              widget.onMaxChanged(maxValue);
                            }
                          : null,
                    ),
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.center,
                        readOnly: true,
                        controller:
                            TextEditingController(text: maxValue.toString()),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: maxValue < widget.max
                          ? () {
                              setState(() {
                                maxValue++;
                              });
                              widget.onMaxChanged(maxValue);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}