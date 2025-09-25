import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'chart_card.dart';

class AgeDemographicsChart extends ConsumerWidget {
  final bool isMobile;

  const AgeDemographicsChart({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);

    return statisticsAsync.when(
      loading: () => ChartCard(
        title: 'Demografía por Edad',
        icon: Icons.groups,
        color: Colors.deepPurple,
        chart: const Center(child: CircularProgressIndicator()),
        isMobile: isMobile,
      ),
      error: (error, stack) => ChartCard(
        title: 'Demografía por Edad',
        icon: Icons.groups,
        color: Colors.deepPurple,
        chart: Center(child: Text('Error: $error')),
        isMobile: isMobile,
      ),
      data: (data) => ChartCard(
        title: 'Demografía por Edad',
        icon: Icons.groups,
        color: Colors.deepPurple,
        chart: data.ageDemographics.isEmpty
            ? const Center(child: Text('No hay datos disponibles'))
            : _buildChart(context, data.ageDemographics),
        isMobile: isMobile,
      ),
    );
  }

  Widget _buildChart(BuildContext context, Map<String, int> ageData) {
    // Define all age groups - ALWAYS show all 6 categories
    final ageGroups = [
      'Primera infancia (0-5)',
      'Infancia (6-11)',
      'Adolescencia (12-18)',
      'Juventud (19-26)',
      'Adultez (27-59)',
      'Vejez (60+)',
    ];

    // Get total for percentage calculation
    final total = ageData.values.fold(0, (sum, count) => sum + count);

    // Colores predefinidos siguiendo el mismo patrón que BaseCharts
    final colors = [
      Colors.pink,
      Colors.orange,
      Colors.yellow[700]!,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    final sections = ageGroups.asMap().entries.map((entry) {
      final index = entry.key;
      final group = entry.value;
      final count = ageData[group] ?? 0;
      final percentage = total > 0 ? (count / total * 100) : 0.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: count > 0 ? count.toDouble() : 0.01, // Minimum value for visibility
        title: count > 0 ? '${percentage.toStringAsFixed(1)}%' : '', // No label for 0%
        radius: isMobile ? 80 : 100,
        titleStyle: TextStyle(
          fontSize: isMobile ? 12 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: isMobile ? 40 : 50,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: ageGroups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
              final count = ageData[group] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getShortName(group),
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getShortName(String group) {
    switch (group) {
      case 'Primera infancia (0-5)':
        return '0-5 años';
      case 'Infancia (6-11)':
        return '6-11 años';
      case 'Adolescencia (12-18)':
        return '12-18 años';
      case 'Juventud (19-26)':
        return '19-26 años';
      case 'Adultez (27-59)':
        return '27-59 años';
      case 'Vejez (60+)':
        return '60+ años';
      default:
        return group;
    }
  }
}