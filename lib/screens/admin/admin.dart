import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/screens/admin/admin_reports.dart';
import 'package:bamx/screens/admin/admin_templates.dart';
import 'package:bamx/screens/admin/admin_management.dart';
import 'package:bamx/screens/login.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: NokeyColorPalette.blue,
          title: const Text(
            'ADMINISTRACIÓN',
            style: TextStyle(
              color: NokeyColorPalette.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: NokeyColorPalette.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: _logout,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: NokeyColorPalette.yellow,
            labelColor: NokeyColorPalette.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'REPORTES GENERADOS'),
              Tab(text: 'MIS PLANTILLAS'),
              Tab(text: 'ADMINISTRADORES'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [AdminReports(), AdminTemplates(), AdminManagement()],
        ),
      ),
    );
  }
}
