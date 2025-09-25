import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'chart_card.dart';
import 'time_period_helpers.dart';

class RevenueChart extends ConsumerStatefulWidget {
  final bool isMobile;

  const RevenueChart({super.key, required this.isMobile});

  @override
  ConsumerState<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends ConsumerState<RevenueChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'day';
  Map<String, double>? _chartData;
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

      final data = await repository.getRevenueByPeriod(
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
      title: 'Ingresos ${TimePeriodHelpers.getPeriodTitle(_selectedPeriod)}',
      icon: Icons.attach_money,
      color: Colors.orange,
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
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.orange,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: TimePeriodHelpers.getAvailablePeriods()
                  .map(
                    (period) => Tab(
                      text: TimePeriodHelpers.getPeriodDisplayName(period),
                    ),
                  )
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
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b).toDouble();

    // Calculate Y interval for revenue values
    double yInterval;
    if (maxValue > 1000) {
      yInterval = (maxValue / 4 / 500).ceil() * 500;
    } else if (maxValue > 500) {
      yInterval = (maxValue / 4 / 100).ceil() * 100;
    } else if (maxValue > 100) {
      yInterval = (maxValue / 4 / 50).ceil() * 50;
    } else if (maxValue > 50) {
      yInterval = (maxValue / 4 / 10).ceil() * 10;
    } else if (maxValue > 10) {
      yInterval = 5;
    } else {
      yInterval = 2;
    }
    if (yInterval == 0) yInterval = 1;

    final maxY = ((maxValue / yInterval).ceil() * yInterval).toDouble();

    // Chart dimensions
    final chartWidth = entries.length * (widget.isMobile ? 80.0 : 100.0);
    const bottomPadding = 60.0;
    const chartHeight = 280.0;

    final lineChartSpots = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value;
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
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.orange,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tooltipMargin: 12,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      tooltipRoundedRadius: 8,
                      tooltipBorder: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final spotIndex = touchedSpot.x.toInt();
                          if (spotIndex >= 0 && spotIndex < entries.length) {
                            final revenue = touchedSpot.y;
                            final formatter = NumberFormat.currency(
                              locale: 'es_MX',
                              symbol: '\$',
                              decimalDigits: 0,
                            );
                            final formattedRevenue = formatter.format(revenue);
                            return LineTooltipItem(
                              formattedRevenue,
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
                      return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: widget.isMobile ? 60 : 70,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          if (value > maxY || value < 0) {
                            return const SizedBox.shrink();
                          }
                          final formatter = NumberFormat('#,###', 'es_MX');
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '\$${formatter.format(value.toInt())}',
                              style: TextStyle(
                                fontSize: widget.isMobile ? 10 : 12,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: bottomPadding,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < entries.length) {
                            final period = entries[index].key;
                            final label = TimePeriodHelpers.formatPeriodLabel(
                              period,
                              _selectedPeriod,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Transform.rotate(
                                angle: -0.4,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: widget.isMobile ? 10 : 12,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
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
