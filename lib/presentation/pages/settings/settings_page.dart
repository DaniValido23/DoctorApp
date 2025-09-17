import 'package:flutter/material.dart';
import 'package:doctor_app/core/widgets/custom_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Configuraciones - Próximamente'),
      ),
    );
  }
}