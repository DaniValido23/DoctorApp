import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BaseCharts {
  static Widget buildCategoricalBarChart(
    Map<String, int> data,
    Color color, {
    required bool isMobile,
    required BuildContext context,
    ScrollController? scrollController,
  }) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    final maxValue = entries.isNotEmpty ? entries.first.value.toDouble() : 1.0;
    // Calculate bar width per item (similar to line charts: entries.length * 60.0)
    final double barSpacing = isMobile ? 80.0 : 100.0;
    final double horizontalPadding = isMobile ? 30.0 : 60.0; // Symmetric padding for tooltips
    final double chartWidth = ((entries.length - 2) * barSpacing) - barSpacing;

    // Calculate Y interval for better grid display
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

    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: color,
            width: isMobile ? 25 : 30,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    // Y-axis chart for labels only
    final yAxisChart = BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isMobile ? 50 : 60,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                final intValue = value.toInt();
                if (value > maxY) return const Text('');

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    intValue.toString(),
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
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
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: isMobile ? 70 : 80, // Same reserved size as main chart for alignment
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [], // Empty bar groups for Y-axis
        minY: 0,
        maxY: maxY + (maxY * 0.1),
      ),
    );

    final mainChart = SizedBox(
      width: chartWidth,
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.start,
          maxY: maxY + (maxY * 0.1),
          minY: 0,
          groupsSpace: isMobile ? 30 : 40,
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
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: isMobile ? 70 : 80,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    final label = entries[index].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: -0.3, // Less rotation for better readability
                        child: Text(
                          label.length > 18 ? '${label.substring(0, 18)}...' : label,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 13, // Larger font size
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
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipMargin: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipBorder: BorderSide(color: Colors.grey.shade300, width: 1),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex >= 0 && groupIndex < entries.length) {
                  final entry = entries[groupIndex];
                  return BarTooltipItem(
                    '${entry.key}\n${entry.value}',
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
    );

    return Column(
      children: [
        // Espacio superior para tooltips
        SizedBox(height: isMobile ? 40 : 50),
        // Contenido principal del gráfico
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eje Y alineado
              SizedBox(
                width: isMobile ? 50 : 60,
                child: yAxisChart,
              ),
              // Gráfico principal con scroll horizontal
              Expanded(
                child: Scrollbar(
                  thumbVisibility: !isMobile,
                  trackVisibility: !isMobile,
                  controller: scrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    child: SizedBox(
                      width: chartWidth + (horizontalPadding * 2),
                      height: 300,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: mainChart,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Espacio inferior para labels
        SizedBox(height: isMobile ? 10 : 15),
      ],
    );
  }

  static Widget buildPieChart(
    Map<String, int> data, {
    required bool isMobile,
  }) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold(0, (sum, entry) => sum + entry.value);

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
    ];

    final sections = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final dataEntry = entry.value;
      final count = dataEntry.value;
      final percentage = total > 0 ? (count / total * 100) : 0.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: count > 0 ? count.toDouble() : 0.01,
        title: count > 0 ? '${percentage.toStringAsFixed(1)}%' : '',
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
            children: entries.take(10).map((entry) {
              final index = entries.indexOf(entry);
              final name = entry.key;
              final count = entry.value;
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
                            name.length > 20 ? '${name.substring(0, 20)}...' : name,
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
}