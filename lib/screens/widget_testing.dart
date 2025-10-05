import 'package:flutter/material.dart';
import 'package:bamx/widgets/form_modules/grid_widget.dart';

class TestGridScreen extends StatelessWidget {
  const TestGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Interactive Grid'),
      ),
      body: Center(
        child: SizedBox(
          height: 350,
          child: InteractiveGrid(
            width: 300,
            height: 300,
            onChanged: (x, y) {
              debugPrint('Selected values → X: $x, Y: $y');
            },
          ),
        ),
      ),
    );
  }
}