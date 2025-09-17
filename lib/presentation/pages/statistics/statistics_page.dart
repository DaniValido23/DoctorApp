import 'package:flutter/material.dart';
import 'package:doctor_app/core/widgets/custom_drawer.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      drawer: const CustomDrawer(),
      body: const Center(
        child: Text('Estadísticas y Gráficos - Próximamente'),
      ),
    );
  }
}