import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/admin_modules/footer_widget.dart';
import 'package:bamx/widgets/admin_modules/button_admin_template.dart';
import 'package:bamx/screens/form_creation.dart';
import 'package:bamx/screens/editable_form.dart';
import 'dart:math';

class AdminTemplates extends StatefulWidget {
  const AdminTemplates({super.key});

  @override
  State<AdminTemplates> createState() => _AdminTemplates();
}

class _AdminTemplates extends State<AdminTemplates> {
  final CollectionReference forms = FirebaseFirestore.instance.collection('forms');

  final Map<String, Color> _assignedColors = {};

  final List<Color> _availableColors = [
    NokeyColorPalette.blue,
    NokeyColorPalette.darkGreen,
    NokeyColorPalette.purple,
    NokeyColorPalette.darkBlue,
    NokeyColorPalette.mexicanPink,
  ];

  Color _getColorForForm(String formId) {
    if (_assignedColors.containsKey(formId)) {
      return _assignedColors[formId]!;
    }
    final random = Random();
    final color = _availableColors[random.nextInt(_availableColors.length)];
    _assignedColors[formId] = color;
    return color;
  }

  Future<void> _deleteForm(String formId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar plantilla'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta plantilla?',
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

    await forms.doc(formId).delete();
    _assignedColors.remove(formId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plantilla eliminada')),
    );
  }

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
                      final String formId = doc.id;
                      final String formName = doc['form_name'] ?? 'Formulario';
                      final buttonColor = _getColorForForm(formId);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ButtonWidget(
                              text: formName,
                              backgroundColor: buttonColor,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FormEditorScreen(formId: formId),
                                  ),
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
                                  onPressed: () => _deleteForm(formId),
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