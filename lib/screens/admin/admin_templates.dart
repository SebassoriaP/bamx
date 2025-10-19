import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/admin_modules/footer_widget.dart';
import 'package:bamx/widgets/admin_modules/button_admin_template.dart';
import 'package:bamx/screens/form_creation.dart';
import 'package:bamx/screens/editable_form.dart';

class AdminTemplates extends StatefulWidget {
  const AdminTemplates({super.key});

  @override
  State<AdminTemplates> createState() => _AdminTemplates();
}

class _AdminTemplates extends State<AdminTemplates> {
  final CollectionReference forms =
      FirebaseFirestore.instance.collection('forms');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'MIS PLANTILLAS',
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
              const SizedBox(height: 14),
                            
              StreamBuilder<QuerySnapshot>(
                stream: forms.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No hay formularios disponibles.');
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final String formId = doc.id; // ID del formulario
                      final String formName = doc['form_name'] ?? 'Formulario';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ButtonWidget(
                          text: formName,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormEditorScreen(formId: formId),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 400),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FooterWidget(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormCreationScreen(),
                    ),
                  );
                },
              ),
              Container(
                width: double.infinity,
                color: NokeyColorPalette.blue,
                padding: const EdgeInsets.only(top: 5, bottom: 25),
                child: const Text(
                  'Agregar Nuevo Reporte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: NokeyColorPalette.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
