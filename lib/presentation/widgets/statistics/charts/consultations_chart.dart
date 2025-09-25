import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'chart_card.dart';
import 'time_period_helpers.dart';

class ConsultationsChart extends ConsumerStatefulWidget {
  final bool isMobile;

  const ConsultationsChart({
    super.key,  
    required this.isMobile,
  });

  @override
  ConsumerState<ConsultationsChart> createState() => _ConsultationsChartState();
}

class _ConsultationsChartState extends ConsumerState<ConsultationsChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'day';
  Map<String, int>? _chartData;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final periods = TimePeriodHelpers.getAvailablePeriods();
    final newPeriod = periods[_tabController.index];

    if (newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
      });
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(statisticsRepositoryProvider);

      // Get all historical data
      final startDate = DateTime(2000);
      final endDate = DateTime.now();

      final data = await repository.getConsultationsByPeriod(
        startDate: startDate,
        endDate: endDate,
        groupBy: _selectedPeriod,
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
      title: 'Consultas ${TimePeriodHelpers.getPeriodTitle(_selectedPeriod)}',
      icon: Icons.medical_services,
      color: Colors.green,
      chart: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: widget.isMobile,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.green,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: TimePeriodHelpers.getAvailablePeriods()
                  .map((period) => Tab(
                        text: TimePeriodHelpers.getPeriodDisplayName(period),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Chart
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chartData == null || _chartData!.isEmpty
                    ? const Center(child: Text('No hay datos disponibles'))
                    : _buildChart(),
          ),
        ],
      ),
      isMobile: widget.isMobile,
    );
  }

  Widget _buildChart() {
    if (_chartData == null || _chartData!.isEmpty) {
      return const Center(child: Text('No hay datos'));
    }

    final entries = _chartData!.entries.toList();
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
    final chartWidth = entries.length * (widget.isMobile ? 80.0 : 100.0);

    const bottomPadding = 60.0;
    const chartHeight = 280.0;

    final lineChartSpots = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value.toDouble();
      return FlSpot(index.toDouble(), value);
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
                    child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: lineChartSpots,
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.green,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              tooltipMargin: 12,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipRoundedRadius: 8,
                              tooltipBorder: BorderSide(color: Colors.grey.shade300, width: 1),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  final spotIndex = touchedSpot.x.toInt();
                                  if (spotIndex >= 0 && spotIndex < entries.length) {
                                    final consultations = touchedSpot.y.toInt();
                                    return LineTooltipItem(
                                      '$consultations consultas',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return null;
                                }).toList();
                              },
                            ),
                          ),
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
                                reservedSize: widget.isMobile ? 35 : 45,
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
                                    final period = entries[index].key;
                                    final label = TimePeriodHelpers.formatPeriodLabel(period, _selectedPeriod);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Transform.rotate(
                                        angle: -0.4,
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: widget.isMobile ? 10 : 12,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
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
                          minY: 0,
                          maxY: maxY,
                        ),
                      ),
                    ),
                ),
              ),
            ),
    );
  }
}