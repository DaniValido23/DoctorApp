import 'package:flutter/material.dart';

class AddPatientPage extends StatelessWidget {
  const AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Paciente'),
      ),
      body: const Center(
        child: Text('Formulario de Paciente - Próximamente'),
      ),
    );
  }
}