import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bamx/utils/color_palette.dart';

class FormResultsScreen extends StatefulWidget {
  final String responseId;

  const FormResultsScreen({super.key, required this.responseId});

  @override
  State<FormResultsScreen> createState() => _FormResultsScreenState();
}

class _FormResultsScreenState extends State<FormResultsScreen> {
  Map<String, dynamic>? responseData;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadResponse();
  }

  Future<void> _loadResponse() async {
    final doc = await FirebaseFirestore.instance
        .collection('form_responses')
        .doc(widget.responseId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    userName = data['user'] ?? 'Usuario desconocido';

    // Parseamos el JSON guardado en 'response'
    final rawResponse = data['response'] ?? '{}';
    try {
      responseData = Map<String, dynamic>.from(jsonDecode(rawResponse));
    } catch (e) {
      responseData = {};
    }

    if (mounted) setState(() {});
  }

  Widget _buildResponseWidget() {
    if (responseData == null || responseData!.isEmpty) {
      return const Text('No hay respuestas disponibles.');
    }

    List<Widget> widgets = [];
    responseData!.forEach((key, value) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: NokeyColorPalette.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: NokeyColorPalette.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (value is Map)
                    ...value.entries.map((entry) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                  color: NokeyColorPalette.black,
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  if (value is! Map)
                    Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: NokeyColorPalette.white, // Arrow back - color
        ),
        
        title: Text(
          'RESULTADOS DE: $userName',
          style: TextStyle(
            color: NokeyColorPalette.white,
            fontWeight: FontWeight.bold
          )  
        ),
        backgroundColor: NokeyColorPalette.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: _buildResponseWidget(),
        ),
      ),
    );
  }
}
