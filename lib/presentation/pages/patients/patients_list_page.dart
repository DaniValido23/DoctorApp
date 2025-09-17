import 'package:flutter/material.dart';
import 'package:doctor_app/core/widgets/custom_drawer.dart';

class PatientsListPage extends StatelessWidget {
  const PatientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Lista de Pacientes - Próximamente'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegación a agregar paciente
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}