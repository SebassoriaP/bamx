import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/screens/login.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/button_widget.dart';
import 'package:bamx/screens/form_creation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color parseColor(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'blanco':
        return NokeyColorPalette.white;
      case 'rojo':
        return NokeyColorPalette.mexicanPink;
      case 'azul':
        return NokeyColorPalette.blue;
      case 'verde':
        return NokeyColorPalette.green;
      case 'amarillo':
        return NokeyColorPalette.yellow;
      default:
        return NokeyColorPalette.blueGrey;
    }
  }

  void _showFormDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    final formName = data['form_name'] ?? 'Formulario sin nombre';
    final created = data['created']?.toString() ?? 'Fecha no disponible';
    final questions = data['questions'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: NokeyColorPalette.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            formName,
            style: const TextStyle(
              color: NokeyColorPalette.purple,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📅 Creado: $created",
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                const Text(
                  "Preguntas:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NokeyColorPalette.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (questions.isEmpty)
                  const Text("No hay preguntas registradas.")
                else
                  ...questions.map((q) {
                    final qName = q['name'] ?? 'Sin nombre';
                    final qType = q['type'] ?? 'Sin tipo';
                    final qMetadata = q['metadata'] ?? 'Sin metadata';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NokeyColorPalette.blueGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• $qName",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text("Tipo: $qType",
                              style: const TextStyle(fontSize: 13)),
                          Text("Metadata: $qMetadata",
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          actions: [
            ButtonWidget(
              text: "Cerrar",
              color: NokeyColorPalette.mexicanPink,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: NokeyColorPalette.blue,
        title: const Text(
          "Formularios",
          style: TextStyle(
            color: NokeyColorPalette.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: NokeyColorPalette.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Bienvenido, ${user?.email ?? 'Usuario'}",
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Divider(thickness: 1, height: 32),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('forms').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No hay formularios disponibles"),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final formName = data['form_name'] ?? 'Sin nombre';
                    final color = NokeyColorPalette.green;

                    return GestureDetector(
                      onTap: () => _showFormDetailsDialog(context, data),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                formName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: NokeyColorPalette.white,
                                ),
                              ),
                            ),
                            const Icon(Icons.info_outline,
                                color: NokeyColorPalette.white),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NokeyColorPalette.yellow,
        child: const Icon(Icons.add, color: NokeyColorPalette.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormCreationScreen()),
          );
        },
      ),
    );
  }
}