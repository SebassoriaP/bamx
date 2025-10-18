import 'package:flutter/material.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/screens/admin/admin_reports.dart';
import 'package:bamx/screens/admin/admin_templates.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: NokeyColorPalette.blue,
          title: const Text(
            'ADMINISTRACIÓN',
            style: TextStyle(
              color: NokeyColorPalette.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: NokeyColorPalette.yellow,
            labelColor: NokeyColorPalette.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'REPORTES GENERADOS'),
              Tab(text: 'MIS PLANTILLAS'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminReports(),
            AdminTemplates(),
          ],
        ),
      ),
    );
  }
}
