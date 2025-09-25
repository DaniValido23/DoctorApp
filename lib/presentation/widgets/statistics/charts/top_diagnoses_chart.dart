import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'chart_card.dart';
import 'base_charts.dart';

class TopDiagnosesChart extends ConsumerStatefulWidget {
  final bool isMobile;

  const TopDiagnosesChart({
    super.key,
    required this.isMobile,
  });

  @override
  ConsumerState<TopDiagnosesChart> createState() => _TopDiagnosesChartState();
}

class _TopDiagnosesChartState extends ConsumerState<TopDiagnosesChart> {
  Map<String, int>? _chartData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
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

      final data = await repository.getMostCommonDiagnosesInDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: 6,
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
      title: 'Diagnósticos Más Comunes',
      icon: Icons.assignment_ind,
      color: Colors.teal,
      chart: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chartData == null || _chartData!.isEmpty
              ? const Center(child: Text('No hay datos disponibles'))
              : BaseCharts.buildPieChart(
                  _chartData!,
                  isMobile: widget.isMobile,
                ),
      isMobile: widget.isMobile,
    );
  }
}