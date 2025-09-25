import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'chart_card.dart';

class FrequentPatientsChart extends ConsumerStatefulWidget {
  final bool isMobile;

  const FrequentPatientsChart({
    super.key,
    required this.isMobile,
  });

  @override
  ConsumerState<FrequentPatientsChart> createState() => _FrequentPatientsChartState();
}

class _FrequentPatientsChartState extends ConsumerState<FrequentPatientsChart> {
  Map<String, int>? _chartData;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(statisticsRepositoryProvider);

      final startDate = DateTime(2000);
      final endDate = DateTime.now();

      final data = await repository.getMostFrequentPatientsInDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: 10,
      );

      setState(() {
        _chartData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Pacientes Más Frecuentes',
      icon: Icons.group,
      color: Colors.blue,
      chart: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chartData == null || _chartData!.isEmpty
              ? const Center(child: Text('No hay datos disponibles'))
              : _buildChart(),
      isMobile: widget.isMobile,
    );
  }

  Widget _buildChart() {
    if (_chartData == null || _chartData!.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final entries = _chartData!.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    final values = entries.map((e) => e.value).toList();
    final maxValue = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b).toDouble();

    // Calculate Y interval for better readability
    double yInterval;
    if (maxValue >= 20) {
      yInterval = (maxValue / 4).round().toDouble();
    } else if (maxValue >= 10) {
      yInterval = (maxValue / 3).round().toDouble();
    } else if (maxValue >= 5) {
      yInterval = 2.0;
    } else {
      yInterval = 1.0;
    }
    if (yInterval < 1) yInterval = 1;

    final maxY = ((maxValue / yInterval).ceil() * yInterval).toDouble();

    // Chart dimensions
    final chartWidth = (entries.length - 1) * (widget.isMobile ? 80.0 : 100.0);
    const bottomPadding = 70.0;
    const chartHeight = 280.0;

    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: Colors.blue,
            width: widget.isMobile ? 30 : 35,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: chartHeight + bottomPadding,
      child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              controller: _scrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: chartWidth,
                    child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.start,
                          maxY: maxY,
                          minY: 0,
                          groupsSpace: widget.isMobile ? 30 : 40,
                          barGroups: barGroups,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: yInterval,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[300]!,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: widget.isMobile ? 45 : 55,
                                interval: yInterval,
                                getTitlesWidget: (value, meta) {
                                  if (value > maxY || value < 0) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: widget.isMobile ? 11 : 13,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: bottomPadding,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < entries.length) {
                                    final label = entries[index].key;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Transform.rotate(
                                        angle: -0.4,
                                        child: Text(
                                          label.length > 18 ? '${label.substring(0, 18)}...' : label,
                                          style: TextStyle(
                                            fontSize: widget.isMobile ? 10 : 12,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              tooltipMargin: 12,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipBorder: BorderSide(color: Colors.grey.shade300, width: 1),
                              tooltipRoundedRadius: 8,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                if (groupIndex >= 0 && groupIndex < entries.length) {
                                  final entry = entries[groupIndex];
                                  return BarTooltipItem(
                                    '${entry.key}\n${entry.value} consultas',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
              ),
            ),
    );
  }
}