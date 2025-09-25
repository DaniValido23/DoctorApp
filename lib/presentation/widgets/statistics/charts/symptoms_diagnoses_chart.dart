import 'package:flutter/material.dart';
import 'package:doctor_app/presentation/providers/providers.dart';

class SymptomsVsDiagnosesChart extends StatefulWidget {
  final StatisticsData data;
  final bool isMobile;

  const SymptomsVsDiagnosesChart({
    super.key,
    required this.data,
    required this.isMobile,
  });

  @override
  State<SymptomsVsDiagnosesChart> createState() => _SymptomsVsDiagnosesChartState();
}

class _SymptomsVsDiagnosesChartState extends State<SymptomsVsDiagnosesChart> {
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _contentHorizontalController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _tableHorizontalController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Sync horizontal scrolling between header and content
    _headerHorizontalController.addListener(() {
      if (_contentHorizontalController.hasClients &&
          _headerHorizontalController.offset != _contentHorizontalController.offset) {
        _contentHorizontalController.jumpTo(_headerHorizontalController.offset);
      }
    });

    _contentHorizontalController.addListener(() {
      if (_headerHorizontalController.hasClients &&
          _contentHorizontalController.offset != _headerHorizontalController.offset) {
        _headerHorizontalController.jumpTo(_contentHorizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerHorizontalController.dispose();
    _contentHorizontalController.dispose();
    _verticalScrollController.dispose();
    _tableHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Custom card with taller height for heatmap
    return Card(
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.deepPurple, size: widget.isMobile ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'Correlación: Síntomas vs Diagnósticos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isMobile ? 16 : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.isMobile ? 16 : 20),
            SizedBox(
              height: widget.isMobile ? 600 : 800, // Taller height for heatmap
              child: widget.data.symptomsVsDiagnoses.isEmpty
                  ? const Center(child: Text('No hay datos disponibles'))
                  : _buildScrollableHeatMap(widget.data.symptomsVsDiagnoses),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableHeatMap(Map<String, Map<String, int>> data) {
    if (data.isEmpty) return const Center(child: Text('No hay datos'));

    // Calculate symptom frequencies (sum of all occurrences per symptom)
    final symptomFrequencies = <String, int>{};
    for (final entry in data.entries) {
      final symptom = entry.key;
      final totalOccurrences = entry.value.values.fold(0, (sum, count) => sum + count);
      symptomFrequencies[symptom] = totalOccurrences;
    }

    // Calculate diagnosis frequencies (sum of all occurrences per diagnosis)
    final diagnosisFrequencies = <String, int>{};
    for (final symptomData in data.values) {
      for (final entry in symptomData.entries) {
        final diagnosis = entry.key;
        final count = entry.value;
        diagnosisFrequencies[diagnosis] = (diagnosisFrequencies[diagnosis] ?? 0) + count;
      }
    }

    // Get top 10 most frequent symptoms and diagnoses
    final topSymptoms = symptomFrequencies.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final top10Symptoms = topSymptoms.take(10).map((e) => e.key).toList();

    final topDiagnoses = diagnosisFrequencies.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final top10Diagnoses = topDiagnoses.take(10).map((e) => e.key).toList();

    // Use only top 10 symptoms and diagnoses
    final allSymptoms = top10Symptoms;
    final diagnosesList = top10Diagnoses;

    // Calculate max value for normalization
    int maxValue = 0;
    for (final symptomData in data.values) {
      for (final count in symptomData.values) {
        if (count > maxValue) maxValue = count;
      }
    }

    // Calculate dimensions - Increased for better readability
    final cellWidth = widget.isMobile ? 100.0 : 130.0;
    final cellHeight = widget.isMobile ? 60.0 : 75.0;
    final headerHeight = widget.isMobile ? 80.0 : 100.0;
    final rowHeaderWidth = widget.isMobile ? 160.0 : 200.0;

    // Calculate exact width needed for the table (with small buffer for borders)
    final tableWidth = rowHeaderWidth + (top10Diagnoses.length * cellWidth) + 4;

    return Column(
      children: [
        // Legend and info
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Text(
                'Top ${allSymptoms.length} síntomas más frecuentes vs Top ${diagnosesList.length} diagnósticos más frecuentes',
                style: TextStyle(
                  fontSize: widget.isMobile ? 11 : 13,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[100]!, Colors.blue[900]!],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menos correlación → Más correlación',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 11 : 13,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Scrollable Heatmap
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final needsHorizontalScroll = tableWidth > availableWidth;

              Widget heatmapWidget = Container(
                width: tableWidth, // Always use the calculated table width
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
            child: Column(
              children: [
                // Fixed header row
                Container(
                  height: headerHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      // Fixed corner cell
                      Container(
                        width: rowHeaderWidth,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: Center(
                          child: Text(
                            'Síntomas \\ Diagnósticos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widget.isMobile ? 10 : 12,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.black : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // Scrollable header columns
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _headerHorizontalController,
                        child: Row(
                              children: diagnosesList.map((diagnosis) {
                                return Container(
                                  width: cellWidth,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border(right: BorderSide(color: Colors.grey[200]!)),
                                  ),
                                  child: Center(
                                    child: RotatedBox(
                                      quarterTurns: widget.isMobile ? 1 : 0,
                                      child: Text(
                                        diagnosis.length > (widget.isMobile ? 12 : 18)
                                            ? '${diagnosis.substring(0, widget.isMobile ? 12 : 18)}...'
                                            : diagnosis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: widget.isMobile ? 11 : 13,
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : null,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: Scrollbar(
                    controller: _verticalScrollController,
                    thumbVisibility: !widget.isMobile,
                    trackVisibility: !widget.isMobile,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fixed row headers
                          SizedBox(
                            width: rowHeaderWidth,
                            child: Column(
                              children: allSymptoms.map((symptom) {
                                return Container(
                                  height: cellHeight,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(
                                      right: BorderSide(color: Colors.grey[300]!),
                                      bottom: BorderSide(color: Colors.grey[200]!),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      symptom.length > (widget.isMobile ? 20 : 28)
                                          ? '${symptom.substring(0, widget.isMobile ? 20 : 28)}...'
                                          : symptom,
                                      style: TextStyle(
                                        fontSize: widget.isMobile ? 11 : 13,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : null,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Scrollable data cells
                          Scrollbar(
                            controller: _contentHorizontalController,
                            thumbVisibility: !widget.isMobile,
                            trackVisibility: !widget.isMobile,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _contentHorizontalController,
                              child: Column(
                                  children: allSymptoms.map((symptom) {
                                    return Row(
                                      children: diagnosesList.map((diagnosis) {
                                        final count = data[symptom]?[diagnosis] ?? 0;
                                        final intensity = maxValue > 0 ? count / maxValue : 0.0;
                                        return Container(
                                          width: cellWidth,
                                          height: cellHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1 + (intensity * 0.8)),
                                            border: Border(
                                              right: BorderSide(color: Colors.grey[200]!),
                                              bottom: BorderSide(color: Colors.grey[200]!),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              count.toString(),
                                              style: TextStyle(
                                                fontSize: widget.isMobile ? 12 : 14,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.white
                                                    : (intensity > 0.5 ? Colors.white : Colors.black87),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            );

            // Always show horizontal scrollbar for desktop UX
            return needsHorizontalScroll
                ? Scrollbar(
                    controller: _tableHorizontalController,
                    thumbVisibility: true, // Always show scrollbar
                    trackVisibility: true, // Always show track
                    child: SingleChildScrollView(
                      controller: _tableHorizontalController,
                      scrollDirection: Axis.horizontal,
                      child: heatmapWidget,
                    ),
                  )
                : Center(child: heatmapWidget);
          },
          ),
        ),
      ],
    );
  }
}