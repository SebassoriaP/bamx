import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/widgets/button_widget.dart';
import 'package:bamx/widgets/admin/footer_widget.dart';

class TestAdminside extends StatefulWidget {
  const TestAdminside({super.key});

  @override
  State<TestAdminside> createState() => _TestAdminside();
}

class _TestAdminside extends State<TestAdminside> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reportes Generados',
          style: TextStyle(
            color: NokeyColorPalette.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: NokeyColorPalette.blue,
      ),

      body: Stack(
        children: [
          // Contenido principal scrollable
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ButtonWidget(
                  text: "Formulario",
                  color: NokeyColorPalette.mexicanPink,
                  onPressed: () => debugPrint('Nuevo formulario Botón'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Aquí va tu contenido principal',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 400), // espacio para scroll y ver footer
              ],
            ),
          ),

          // Footer fijo abajo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min, // importante para que no crezca
              children: [
                // Botón circular con fondo dividido (FooterWidget)
                FooterWidget(
                  onPressed: () => debugPrint('Nuevo reporte - Button'),
                ),

                // Texto con fondo azul ocupando todo el ancho
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
      ),
    );
  }
}
