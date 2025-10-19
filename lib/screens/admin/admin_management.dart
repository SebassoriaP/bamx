import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/utils/warning.dart';

class AdminManagement extends StatefulWidget {
  const AdminManagement({super.key});

  @override
  State<AdminManagement> createState() => _AdminManagementState();
}

class _AdminManagementState extends State<AdminManagement> {
  final TextEditingController _emailController = TextEditingController();
  final CollectionReference _adminsRef =
      FirebaseFirestore.instance.collection('admins');

  Future<void> _addAdmin() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showErrorMessage(context, "Por favor, ingresa un correo.");
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Agregar "$email" como administrador?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NokeyColorPalette.blue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Check if already exists
      final existingAdmin = await _adminsRef.where('email', isEqualTo: email).get();
      if (existingAdmin.docs.isNotEmpty) {
        showErrorMessage(context, "Este usuario ya es administrador.");
        return;
      }

      await _adminsRef.add({
        'email': email,
        'createdAt': DateTime.now(),
      });

      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Administrador "$email" agregado.')),
      );
    } catch (e) {
      showErrorMessage(context, "Error al agregar administrador: $e");
    }
  }

  Future<void> _removeAdmin(String docId, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar administrador'),
        content: Text('¿Eliminar "$email" de los administradores?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NokeyColorPalette.mexicanPink),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _adminsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Administrador "$email" eliminado.')),
      );
    } catch (e) {
      showErrorMessage(context, "Error al eliminar administrador: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _addAdmin,
            style:
                ElevatedButton.styleFrom(backgroundColor: NokeyColorPalette.yellow),
            child: const Text(
                'Agregar administrador',
                style: TextStyle(color: NokeyColorPalette.darkBlue),
            ),
          ),
          const Divider(height: 32),
          const Text(
            'Administradores actuales',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminsRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay administradores registrados.'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final email = doc['email'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(email),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: NokeyColorPalette.mexicanPink),
                          onPressed: () => _removeAdmin(doc.id, email),
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
    );
  }
}