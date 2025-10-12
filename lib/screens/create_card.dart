import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/screens/home.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final TextEditingController nameController = TextEditingController();
  String selectedColor = 'blanco';

  final List<String> colors = ['blanco', 'rojo', 'azul', 'verde', 'amarillo'];

  Future<void> addCard() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Espera a que se agregue el documento
    await FirebaseFirestore.instance.collection('forms').add({
      'nombre': name,
      'color': selectedColor,
      'creacion': DateTime.now(),
    });

    // Revisa mounted inmediatamente después del await
    if (!mounted) return;

    // Mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario creado con éxito'),
        backgroundColor: Colors.green,
      ),
    );

    // Redirige a HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear un Nuevo Formulario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del formulario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedColor,
              items: colors
                  .map(
                    (color) => DropdownMenuItem(
                      value: color,
                      child: Text(color[0].toUpperCase() + color.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedColor = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Crear Formulario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
