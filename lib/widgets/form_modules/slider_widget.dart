import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final String question;
  final ValueChanged<double>? onChanged;
  final double topPadding;

  const CustomSlider({
    super.key,
    required this.question,
    this.min = 0,
    this.max = 100,
    this.initialValue = 50,
    this.onChanged,
    this.topPadding = 40.0,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: widget.topPadding),

        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            widget.question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 20, //Bar size
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 20, // Ball radious
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 22, // Slider effect
            ),
            thumbColor: Color.fromRGBO(255, 195, 0, 1), // Ball color
            activeTrackColor: const Color.fromRGBO(116, 185, 228, 1),
            inactiveTrackColor: Colors.deepPurple.shade100,
            overlayColor: Color.fromARGB(241, 255, 213, 75).withValues(),
            valueIndicatorColor: Colors.deepPurple,
          ),
          child: Slider(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            label: _currentValue.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
              widget.onChanged?.call(value);
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentValue.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
