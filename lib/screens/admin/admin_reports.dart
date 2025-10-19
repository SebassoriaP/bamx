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
  final CollectionReference forms = FirebaseFirestore.instance.collection(
    'forms',
  );
  final CollectionReference formsRes = FirebaseFirestore.instance.collection(
    'form_responses',
  );

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
          
          const SizedBox(height: 14),
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
                  final formRef = data['form_id'];

                  if (formRef == null || formRef is! DocumentReference) {
                    return const Text('Error: form_id inválido.');
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: formRef.get(),
                    builder: (context, formSnapshot) {
                      if (formSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!formSnapshot.hasData || !formSnapshot.data!.exists) {
                        return const Text('Formulario no encontrado.');
                      }

                      final formData =
                          formSnapshot.data!.data() as Map<String, dynamic>;
                      final formName =
                          formData['form_name'] ?? 'Formulario sin nombre';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ButtonWidget(
                          user: user,
                          text: formName,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormResultsScreen(
                                  responseId: doc.id, 
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
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
