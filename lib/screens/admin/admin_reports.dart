import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/admin_modules/button_admin_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/screens/form_results.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  State<AdminReports> createState() => _AdminReports();
}

class _AdminReports extends State<AdminReports> {
  final CollectionReference formsRes = FirebaseFirestore.instance.collection(
    'form_responses',
  );

  final Map<String, Color> _assignedColors = {};

  final List<Color> _availableColors = [
    NokeyColorPalette.blue,
    NokeyColorPalette.darkGreen,
    NokeyColorPalette.purple,
    NokeyColorPalette.darkBlue,
    NokeyColorPalette.mexicanPink,
  ];

  Color _getColorForDoc(String docId) {
    if (_assignedColors.containsKey(docId)) {
      return _assignedColors[docId]!;
    }
    final color =
        _availableColors[_assignedColors.length % _availableColors.length];
    _assignedColors[docId] = color;
    return color;
  }

  Future<String> getFormName(DocumentReference? formRef) async {
    if (formRef == null) return 'Respuesta Generada con Plantilla Borrada';
    try {
      final snapshot = await formRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        return data?['form_name'] ?? 'Respuesta Generada con Plantilla Borrada';
      }
    } catch (_) {}
    return 'Answer from unanswered form';
  }

  Future<void> deleteResponse(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar respuesta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta respuesta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await formsRes.doc(docId).delete();
      _assignedColors.remove(docId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Respuesta eliminada correctamente',
            style: TextStyle(color: NokeyColorPalette.black),
          ),
          backgroundColor: NokeyColorPalette.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: NokeyColorPalette.mexicanPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 19),
          const Text(
            'REPORTES GENERADOS',
            style: TextStyle(
              color: NokeyColorPalette.blue,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 5),
          const Divider(
            color: NokeyColorPalette.blue,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 19),
          StreamBuilder<QuerySnapshot>(
            stream: formsRes.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No hay reportes disponibles.');
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final user = data['user'] ?? 'Usuario desconocido';
                  final rawFormRef = data['form_id'];

                  DocumentReference? formRef;
                  if (rawFormRef is DocumentReference) {
                    formRef = rawFormRef;
                  }

                  final buttonColor = _getColorForDoc(doc.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FutureBuilder<String>(
                          future: getFormName(formRef),
                          builder: (context, formNameSnapshot) {
                            final formName =
                                formNameSnapshot.data ??
                                'Respuesta Generada con Plantilla Borrada';
                            return ButtonWidget(
                              user: user,
                              text: "Respuesta generada con $formName",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FormResultsScreen(responseId: doc.id),
                                  ),
                                );
                              },
                              backgroundColor: buttonColor,
                            );
                          },
                        ),
                        Positioned(
                          right: -15,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: NokeyColorPalette.mexicanPink,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () => deleteResponse(doc.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
