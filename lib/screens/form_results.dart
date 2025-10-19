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
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Card(
            color: NokeyColorPalette.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 
                  Text(
                    key,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      color: NokeyColorPalette.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (value is Map)
                    ...value.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left variable
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                color: NokeyColorPalette.darkGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Answer
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: NokeyColorPalette.blue,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                entry.value.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: NokeyColorPalette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (value is! Map)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: NokeyColorPalette.blue,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        value.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: NokeyColorPalette.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: NokeyColorPalette.white,
        ),
        title: Text(
          'RESULTADOS DE: $userName',
          style: const TextStyle(
            color: NokeyColorPalette.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: NokeyColorPalette.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildResponseWidget(),
        ),
      ),
    );
  }
}
