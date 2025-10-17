import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/screens/login.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/screens/form_creation.dart';
import 'package:bamx/screens/form_render.dart';

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
                    final formName = data['form_name'] ?? 'Sin nombre';
                    final color = NokeyColorPalette.green;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormRenderScreen(formData: data),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 4,
                              offset: Offset(2, 2),
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
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: NokeyColorPalette.white,
                            ),
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
