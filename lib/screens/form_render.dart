import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/form_modules/grid_widget.dart';
import 'package:bamx/widgets/form_modules/slider_widget.dart';
import 'package:bamx/widgets/form_modules/card_widget.dart';
import 'package:bamx/widgets/form_modules/checkbox_widget.dart';
import 'package:bamx/widgets/form_modules/textbox_widget.dart';
import 'package:bamx/screens/home.dart';

class FormRenderScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final String formId;

  const FormRenderScreen({
    super.key,
    required this.formData,
    required this.formId,
  });

  @override
  State<FormRenderScreen> createState() => _FormRenderScreenState();
}

class _FormRenderScreenState extends State<FormRenderScreen> {
  final Map<String, dynamic> _responses = {};

  @override
  Widget build(BuildContext context) {
    final formName = widget.formData['form_name'] ?? 'Formulario sin nombre';
    final questionsRaw = widget.formData['questions'];

    List<Map<String, dynamic>> questions = [];
    if (questionsRaw is List) {
      questions = List<Map<String, dynamic>>.from(questionsRaw);
    } else if (questionsRaw is Map) {
      questions = questionsRaw.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else if (questionsRaw != null) {
      questions = [Map<String, dynamic>.from(questionsRaw)];
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: NokeyColorPalette.white),
        backgroundColor: NokeyColorPalette.blue,
        title: Text(
          formName,
          style: const TextStyle(
            color: NokeyColorPalette.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            for (final q in questions) _buildComponentForQuestion(q),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NokeyColorPalette.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await _submitForm(widget.formId);
              },
              child: const Text(
                "Enviar respuestas",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentForQuestion(Map<String, dynamic> question) {
    final type = (question['type'] ?? 'unknown').toString();
    final name = question['name'] ?? 'Pregunta sin nombre';
    final rawMetadata = question['metadata'];

    Map<String, dynamic> metadataMap = {};
    List<Map<String, dynamic>> metadataList = [];
    List<String> metadataStrings = [];

    if (rawMetadata is Map) {
      metadataMap = Map<String, dynamic>.from(rawMetadata);
    } else if (rawMetadata is List) {
      if (rawMetadata.isNotEmpty && rawMetadata.first is Map) {
        metadataList = rawMetadata
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (rawMetadata.isNotEmpty && rawMetadata.first is String) {
        metadataStrings = List<String>.from(rawMetadata);
      }
    } else if (rawMetadata is String && rawMetadata.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMetadata);
        if (decoded is Map) {
          metadataMap = Map<String, dynamic>.from(decoded);
        } else if (decoded is List) {
          if (decoded.isNotEmpty && decoded.first is Map) {
            metadataList = decoded
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          } else if (decoded.isNotEmpty && decoded.first is String) {
            metadataStrings = List<String>.from(decoded);
          }
        }
      } catch (e) {
        debugPrint('Error parsing metadata JSON: $e');
      }
    }

    switch (type) {
      case 'Grid':
        double minx = metadataList.isNotEmpty
            ? double.tryParse(metadataList[0]['min'].toString()) ?? 0
            : 0;
        double maxx = metadataList.isNotEmpty
            ? double.tryParse(metadataList[0]['max'].toString()) ?? 100
            : 100;
        String namex = metadataList.isNotEmpty
            ? metadataList[0]['name'].toString()
            : 'x';

        double miny = metadataList.length > 1
            ? double.tryParse(metadataList[1]['min'].toString()) ?? 0
            : 0;
        double maxy = metadataList.length > 1
            ? double.tryParse(metadataList[1]['max'].toString()) ?? 100
            : 100;
        String namey = metadataList.length > 1
            ? metadataList[1]['name'].toString()
            : 'y';

        return InteractiveGrid(
          title: name,
          xLabel: namex,
          yLabel: namey,
          xMin: minx,
          xMax: maxx,
          yMin: miny,
          yMax: maxy,
          width: 300,
          height: 300,
          onChanged: (x, y) {
            _responses[name] = {
              'x': {'value': x, 'min': minx, 'max': maxx, 'label': namex},
              'y': {'value': y, 'min': miny, 'max': maxy, 'label': namey},
            };
          },
        );

      case 'Slider':
        double min = metadataList.isNotEmpty
            ? double.tryParse(metadataList[0]['min'].toString()) ?? 0
            : 0;
        double max = metadataList.isNotEmpty
            ? double.tryParse(metadataList[0]['max'].toString()) ?? 100
            : 100;

        return CustomSlider(
          topPadding: 20,
          question: name,
          min: min,
          max: max,
          initialValue: (min + max) / 2,
          onChanged: (value) {
            setState(() {
              _responses[name] = {'value': value, 'min': min, 'max': max};
            });
          },
        );

      case 'Checkbox':
        List<String> options = [];
        if (metadataList.isNotEmpty) {
          options = metadataList
              .map((e) => e['name']?.toString() ?? '')
              .toList();
        } else if (metadataStrings.isNotEmpty) {
          options = metadataStrings;
        } else if (metadataMap.containsKey('options')) {
          options = List<String>.from(metadataMap['options']);
        }

        return MultipleChoiceQuestion(
          question: name,
          options: options,
          onChanged: (selected) {
            _responses[name] = {for (var o in options) o: selected.contains(o)};
          },
        );

      case 'Card Swipe':
        List<String> cards = [];
        if (metadataList.isNotEmpty) {
          cards = metadataList.map((e) => e['name']?.toString() ?? '').toList();
        } else if (metadataStrings.isNotEmpty) {
          cards = metadataStrings;
        } else if (metadataMap.containsKey('cards')) {
          cards = List<String>.from(metadataMap['cards']);
        }

        return CardWidget(
          height: 400,
          title: name,
          questions: cards.isNotEmpty ? cards : ['Error: sin cards'],
          onAnswered: (question, answer) {
            _responses[name] ??= {};
            _responses[name][question] = answer;
          },
        );

      case 'Textbox':
        return CustomTextField(
          label: name,
          hint: metadataMap['hint']?.toString() ?? "Escribe aquí...",
          onChanged: (value) {
            _responses[name] = value;
          },
        );

      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "Tipo desconocido o no definido: $type",
            style: const TextStyle(color: Colors.grey),
          ),
        );
    }
  }

  Future<void> _submitForm(String formId) async {
    try {
      final responseJson = jsonEncode(_responses);

      final User? user = FirebaseAuth.instance.currentUser;
      String email = 'No email';

      if (user != null && user.email != null) {
        email = user.email!;
      } else {
        debugPrint('Error fetching user');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo obtener el usuario"),
            backgroundColor: NokeyColorPalette.mexicanPink,
          ),
        );
        return;
      }

      final dataToSend = {
        'form_id': FirebaseFirestore.instance.doc('forms/$formId'),
        'response': responseJson,
        'timestamp': FieldValue.serverTimestamp(),
        'user': email,
      };

      debugPrint('Sending form responses to Firestore:');
      debugPrint(dataToSend.toString());

      await FirebaseFirestore.instance
          .collection('form_responses')
          .add(dataToSend);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Respuestas enviadas correctamente a nombre de $email",
            style: const TextStyle(color: NokeyColorPalette.black),
          ),
          backgroundColor: NokeyColorPalette.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al enviar: $e"),
          backgroundColor: NokeyColorPalette.mexicanPink,
        ),
      );
    }
  }
}
