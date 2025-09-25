import 'package:intl/intl.dart';

class TimePeriodHelpers {
  static String formatPeriodLabel(String period, String groupBy) {
    try {
      switch (groupBy) {
        case 'day':
          final date = DateTime.parse(period);
          return DateFormat('dd/MM/yyyy').format(date);
        case 'week':
          // Format: 2024-W45 -> Sem 45
          final parts = period.split('-W');
          if (parts.length == 2) {
            return 'Sem ${parts[1]}';
          }
          return period;
        case 'month':
          // Format: 2024-03 -> Mar 2024
          final parts = period.split('-');
          if (parts.length == 2) {
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final date = DateTime(year, month);
            return DateFormat('MMM yyyy', 'es').format(date);
          }
          return period;
        case 'year':
          return period;
        default:
          return period;
      }
    } catch (e) {
      return period;
    }
  }

  static String getPeriodTitle(String groupBy) {
    switch (groupBy) {
      case 'day':
        return 'por Día';
      case 'week':
        return 'por Semana';
      case 'month':
        return 'por Mes';
      case 'year':
        return 'por Año';
      default:
        return '';
    }
  }

  static List<String> getAvailablePeriods() {
    return ['day', 'week', 'month', 'year'];
  }

  static String getPeriodDisplayName(String period) {
    switch (period) {
      case 'day':
        return 'Día';
      case 'week':
        return 'Semana';
      case 'month':
        return 'Mes';
      case 'year':
        return 'Año';
      default:
        return period;
    }
  }
}