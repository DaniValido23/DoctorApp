import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'chart_card.dart';

class WeightEvolutionChart extends StatelessWidget {
  final StatisticsData data;
  final bool isMobile;

  const WeightEvolutionChart({
    super.key,
    required this.data,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Evolución de Peso',
      icon: Icons.monitor_weight_outlined,
      color: Colors.cyan,
      chart: data.recurringPatientsWeightEvolution.isEmpty
          ? const Center(child: Text('No hay pacientes con datos de peso en múltiples consultas'))
          : WeightEvolutionSelector(data: data, isMobile: isMobile),
      isMobile: isMobile,
    );
  }
}

class WeightEvolutionSelector extends StatefulWidget {
  final StatisticsData data;
  final bool isMobile;

  const WeightEvolutionSelector({
    super.key,
    required this.data,
    required this.isMobile,
  });

  @override
  State<WeightEvolutionSelector> createState() => _WeightEvolutionSelectorState();
}

class _WeightEvolutionSelectorState extends State<WeightEvolutionSelector> {
  String? selectedPatient;

  @override
  void initState() {
    super.initState();
    // Seleccionar el primer paciente por defecto
    if (widget.data.recurringPatientsWeightEvolution.isNotEmpty) {
      selectedPatient = widget.data.recurringPatientsWeightEvolution.keys.first;
    }
  }

  @override
  void didUpdateWidget(WeightEvolutionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si los datos cambiaron, verificar que el paciente seleccionado aún existe
    if (selectedPatient != null &&
        !widget.data.recurringPatientsWeightEvolution.containsKey(selectedPatient)) {
      selectedPatient = widget.data.recurringPatientsWeightEvolution.isNotEmpty
          ? widget.data.recurringPatientsWeightEvolution.keys.first
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.recurringPatientsWeightEvolution.isEmpty) {
      return const Center(child: Text('No hay pacientes con datos de peso en múltiples consultas'));
    }

    final patientNames = widget.data.recurringPatientsWeightEvolution.keys.toList();

    return Column(
      children: [
        // Selector de paciente
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 12 : 16,
            vertical: widget.isMobile ? 8 : 12,
          ),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.cyan[700],
                size: widget.isMobile ? 18 : 20,
              ),
              SizedBox(width: widget.isMobile ? 8 : 12),
              Text(
                'Paciente:',
                style: TextStyle(
                  fontSize: widget.isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPatient,
                    isDense: true,
                    isExpanded: true,
                    style: TextStyle(
                      fontSize: widget.isMobile ? 14 : 16,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[800],
                    ),
                    items: patientNames.map((patientName) {
                      final consultationCount = widget.data.recurringPatientsWeightEvolution[patientName]?.length ?? 0;
                      return DropdownMenuItem<String>(
                        value: patientName,
                        child: Text(
                          '$patientName ($consultationCount consultas)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPatient = newValue;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Gráfica del paciente seleccionado
        Expanded(
          child: selectedPatient != null
              ? _buildSinglePatientWeightChart(
                  selectedPatient!,
                  widget.data.recurringPatientsWeightEvolution[selectedPatient!]!,
                )
              : const Center(child: Text('Selecciona un paciente')),
        ),
      ],
    );
  }

  Widget _buildSinglePatientWeightChart(
    String patientName,
    List<Map<String, dynamic>> patientData,
  ) {
    if (patientData.isEmpty) return const Center(child: Text('No hay datos para este paciente'));

    // Ordenar datos por fecha
    final sortedData = List<Map<String, dynamic>>.from(patientData);
    sortedData.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

    final spots = sortedData.asMap().entries.map((entry) {
      final weight = entry.value['weight'] as double;
      return FlSpot(entry.key.toDouble(), weight);
    }).toList();

    final weights = sortedData.map((d) => d['weight'] as double).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    final padding = weightRange > 0 ? weightRange * 0.1 : 2.0;

    return Column(
      children: [
        // Información del paciente
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.cyan[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.cyan[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.cyan[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  patientName,
                  style: TextStyle(
                    fontSize: widget.isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[800],
                  ),
                ),
              ),
              _buildWeightChangeIndicator(weights),
            ],
          ),
        ),
        // Gráfica
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: weightRange > 10 ? 5 : 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: widget.isMobile ? 60 : 80,
                    interval: sortedData.length > 6 ? (sortedData.length / 4).round().toDouble() : 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < sortedData.length) {
                        final date = sortedData[index]['date'] as String;
                        final parts = date.split('-');
                        if (parts.length >= 3) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                '${parts[2]}/${parts[1]}',
                                style: TextStyle(
                                  fontSize: widget.isMobile ? 10 : 12,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: widget.isMobile ? 50 : 60,
                    interval: weightRange > 10 ? 5 : 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toStringAsFixed(1)}kg',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 10 : 12,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              minX: 0,
              maxX: (sortedData.length - 1).toDouble(),
              minY: minWeight - padding,
              maxY: maxWeight + padding,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.cyan,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: Colors.cyan,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.cyan.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChangeIndicator(List<double> weights) {
    if (weights.length < 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Sin tendencia',
          style: TextStyle(
            fontSize: widget.isMobile ? 12 : 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final firstWeight = weights.first;
    final lastWeight = weights.last;
    final difference = lastWeight - firstWeight;
    final percentChange = (difference / firstWeight * 100);

    final isPositive = difference > 0.5;
    final isNegative = difference < -0.5;

    Color color;
    IconData icon;
    String text;

    if (isPositive) {
      color = Colors.orange;
      icon = Icons.trending_up;
      text = '+${difference.toStringAsFixed(1)}kg (${percentChange.toStringAsFixed(1)}%)';
    } else if (isNegative) {
      color = Colors.green;
      icon = Icons.trending_down;
      text = '${difference.toStringAsFixed(1)}kg (${percentChange.toStringAsFixed(1)}%)';
    } else {
      color = Colors.blue;
      icon = Icons.trending_flat;
      text = 'Estable (${difference.toStringAsFixed(1)}kg)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: widget.isMobile ? 14 : 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: widget.isMobile ? 11 : 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}