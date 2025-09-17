import 'package:flutter/material.dart';

class ConsultationPage extends StatelessWidget {
  final int patientId;

  const ConsultationPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta - Paciente $patientId'),
      ),
      body: const Center(
        child: Text('Formulario de Consulta - Próximamente'),
      ),
    );
  }
}