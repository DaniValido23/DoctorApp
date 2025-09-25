import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:doctor_app/presentation/providers/statistics_provider.dart';
import 'package:doctor_app/core/utils/responsive_utils.dart';
import 'package:doctor_app/core/widgets/custom_drawer.dart';
import 'package:doctor_app/presentation/widgets/statistics/charts/charts.dart';
import 'package:doctor_app/presentation/widgets/statistics/charts/consultations_chart.dart' as new_charts;
import 'package:doctor_app/presentation/widgets/statistics/charts/revenue_chart.dart' as new_charts;

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      drawer: const CustomDrawer(),
      body: statisticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text('Error al cargar estadísticas: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(statisticsProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (data) => ResponsiveLayout(
          mobile: _buildMobileLayout(context, ref, data),
          desktop: _buildDesktopLayout(context, ref, data),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    StatisticsData data,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, data, isMobile: true),
          const SizedBox(height: 24),
          new_charts.ConsultationsChart(isMobile: true),
          const SizedBox(height: 24),
          new_charts.RevenueChart(isMobile: true),
          const SizedBox(height: 24),
          FrequentPatientsChart(isMobile: true),
          const SizedBox(height: 24),
          TopSymptomsChart(isMobile: true),
          const SizedBox(height: 24),
          TopMedicationsChart(isMobile: true),
          const SizedBox(height: 24),
          TopDiagnosesChart(isMobile: true),
          const SizedBox(height: 24),
          AgeDemographicsChart(isMobile: true),
          const SizedBox(height: 24),
          WeightEvolutionChart(data: data, isMobile: true),
          const SizedBox(height: 24),
          SymptomsVsDiagnosesChart(data: data, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    StatisticsData data,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, data, isMobile: false),
          const SizedBox(height: 32),
          // First row of charts
          Row(
            children: [
              Expanded(child: new_charts.ConsultationsChart(isMobile: false)),
              const SizedBox(width: 16),
              Expanded(child: new_charts.RevenueChart(isMobile: false)),
            ],
          ),
          const SizedBox(height: 24),
          // Second row of charts
          Row(
            children: [
              Expanded(child: FrequentPatientsChart(isMobile: false)),
              const SizedBox(width: 16),
              Expanded(child: TopSymptomsChart(isMobile: false)),
            ],
          ),
          const SizedBox(height: 24),
          // Third row of charts
          Row(
            children: [
              Expanded(child: TopMedicationsChart(isMobile: false)),
              const SizedBox(width: 16),
              Expanded(child: TopDiagnosesChart(isMobile: false)),
            ],
          ),
          const SizedBox(height: 24),
          // Fourth row of charts
          Row(
            children: [
              Expanded(child: WeightEvolutionChart(data: data, isMobile: false)),
              const SizedBox(width: 16),
              Expanded(child: AgeDemographicsChart(isMobile: false)),
            ],
          ),
          const SizedBox(height: 24),
          // Full width heatmap at bottom
          SymptomsVsDiagnosesChart(data: data, isMobile: false),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, StatisticsData data, {required bool isMobile}) {
    final cards = [
      _buildSummaryCard(
        context,
        'Total Pacientes',
        data.totalPatients.toString(),
        Icons.group,
        Colors.blue,
      ),
      _buildSummaryCard(
        context,
        'Consultas Totales',
        data.totalConsultations.toString(),
        Icons.medical_services,
        Colors.green,
      ),
      _buildSummaryCard(
        context,
        'Ingresos Totales',
        NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(data.totalRevenue),
        Icons.attach_money,
        Colors.orange,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: card,
        )).toList(),
      );
    } else {
      return Row(
        children: cards.map((card) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: card,
          ),
        )).toList(),
      );
    }
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}