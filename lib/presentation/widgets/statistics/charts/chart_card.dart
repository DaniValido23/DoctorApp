import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget chart;
  final bool isMobile;
  final double? customHeight;

  const ChartCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.chart,
    required this.isMobile,
    this.customHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isMobile ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            SizedBox(
              height: customHeight ?? (isMobile ? 300 : 480),
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}
