import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/screens/login.dart';
import 'package:bamx/screens/create_card.dart';
import 'package:bamx/utils/color_palette.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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

          // === Firestore list of forms ===
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forms')
                  .snapshots(),
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
                    final name = data['nombre'] ?? 'Sin nombre';
                    final colorString = data['color'] ?? 'gris';
                    final color = parseColor(colorString);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.2 * 255).toInt()),
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
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                color: color.computeLuminance() > 0.5
                                    ? NokeyColorPalette.black
                                    : NokeyColorPalette.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Botón presionado: $name'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: NokeyColorPalette.mexicanPink,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: NokeyColorPalette.black,
                            ),
                          ),
                        ],
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
            MaterialPageRoute(builder: (_) => const CreateCardScreen()),
          );
        },
      ),
    );
  }
}
