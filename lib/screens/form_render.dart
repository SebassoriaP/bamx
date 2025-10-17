import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/form_modules/grid_widget.dart';
import 'package:bamx/widgets/form_modules/slider_widget.dart';
import 'package:bamx/widgets/form_modules/card_widget.dart';
import 'package:bamx/widgets/form_modules/checkbox_widget.dart';
import 'package:bamx/widgets/form_modules/textbox_widget.dart';

class FormRenderScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const FormRenderScreen({super.key, required this.formData});

  @override
  State<FormRenderScreen> createState() => _FormRenderScreenState();
}

class _FormRenderScreenState extends State<FormRenderScreen> {
  double _sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    final formName = widget.formData['form_name'] ?? 'Formulario sin nombre';
    final questionsRaw = widget.formData['questions'];

    // Normalizamos el formato de questions
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
          children: [for (final q in questions) _buildComponentForQuestion(q)],
        ),
      ),
    );
  }

  Widget _buildComponentForQuestion(Map<String, dynamic> question) {
    final type = (question['type'] ?? 'unknown').toString();
    final name = question['name'] ?? 'Pregunta sin nombre';
    final rawMetadata = question['metadata'];

    // 🔹 Preparar variables para diferentes tipos de metadata
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
        debugPrint('⚠️ Error parsing metadata JSON: $e');
      }
    }

    switch (type) {
      case 'Grid':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            height: 300,
            child: InteractiveGrid(
              width: 300,
              height: 300,
              onChanged: (x, y) {},
            ),
          ),
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
          initialValue: _sliderValue,
          onChanged: (value) {
            setState(() => _sliderValue = value);
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
          onChanged: (selected) {},
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
          onAnswered: (question, answer) {},
        );

      case 'Textbox':
        return CustomTextField(
          label: name,
          hint: metadataMap['hint']?.toString() ?? "Escribe aquí...",
          onChanged: (value) => {},
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
}
