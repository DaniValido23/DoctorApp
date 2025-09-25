import 'package:sqflite/sqflite.dart';
import 'package:doctor_app/data/database/database_helper.dart';
import 'package:doctor_app/core/constants/database_constants.dart';

class StatisticsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _database async => await _databaseHelper.database;

  // Get total number of patients
  Future<int> getTotalPatients() async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseConstants.patientsTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total number of consultations
  Future<int> getTotalConsultations() async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseConstants.consultationsTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get patients by day (for chart)
  Future<Map<String, int>> getPatientsByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT DATE(${DatabaseConstants.columnConsultationDate}) as date,
             COUNT(DISTINCT ${DatabaseConstants.columnConsultationPatientId}) as count
      FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY DATE(${DatabaseConstants.columnConsultationDate})
      ORDER BY date
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, int> patientsByDay = {};
    for (final row in result) {
      patientsByDay[row['date'] as String] = row['count'] as int;
    }

    return patientsByDay;
  }

  // Get most frequent symptoms
  Future<Map<String, int>> getMostFrequentSymptoms({int limit = 10}) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT s.${DatabaseConstants.columnSymptomName} as symptom, COUNT(*) as count
      FROM ${DatabaseConstants.symptomsTable} s
      INNER JOIN ${DatabaseConstants.consultationSymptomsTable} cs
        ON s.${DatabaseConstants.columnId} = cs.${DatabaseConstants.columnJunctionSymptomId}
      GROUP BY s.${DatabaseConstants.columnSymptomName}
      ORDER BY count DESC
      LIMIT ?
    ''', [limit]);

    final Map<String, int> symptoms = {};
    for (final row in result) {
      symptoms[row['symptom'] as String] = row['count'] as int;
    }

    return symptoms;
  }

  // Get most prescribed medications
  Future<Map<String, int>> getMostPrescribedMedications({int limit = 10}) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT ${DatabaseConstants.columnMedicationName} as medication, COUNT(*) as count
      FROM ${DatabaseConstants.medicationsTable}
      GROUP BY ${DatabaseConstants.columnMedicationName}
      ORDER BY count DESC
      LIMIT ?
    ''', [limit]);

    final Map<String, int> medications = {};
    for (final row in result) {
      medications[row['medication'] as String] = row['count'] as int;
    }

    return medications;
  }

  // Get most common diagnoses
  Future<Map<String, int>> getMostCommonDiagnoses({int limit = 10}) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT d.${DatabaseConstants.columnDiagnosisName} as diagnosis, COUNT(*) as count
      FROM ${DatabaseConstants.diagnosesTable} d
      INNER JOIN ${DatabaseConstants.consultationDiagnosesTable} cd
        ON d.${DatabaseConstants.columnId} = cd.${DatabaseConstants.columnJunctionDiagnosisId}
      GROUP BY d.${DatabaseConstants.columnDiagnosisName}
      ORDER BY count DESC
      LIMIT ?
    ''', [limit]);

    final Map<String, int> diagnoses = {};
    for (final row in result) {
      diagnoses[row['diagnosis'] as String] = row['count'] as int;
    }

    return diagnoses;
  }

  // Get revenue by period (daily)
  Future<Map<String, double>> getRevenueByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT DATE(${DatabaseConstants.columnConsultationDate}) as date,
             SUM(${DatabaseConstants.columnConsultationPrice}) as revenue
      FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY DATE(${DatabaseConstants.columnConsultationDate})
      ORDER BY date
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, double> revenueByDay = {};
    for (final row in result) {
      revenueByDay[row['date'] as String] = (row['revenue'] as num).toDouble();
    }

    return revenueByDay;
  }

  // Get revenue by period (monthly)
  Future<Map<String, double>> getRevenueByMonth({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT strftime('%Y-%m', ${DatabaseConstants.columnConsultationDate}) as month,
             SUM(${DatabaseConstants.columnConsultationPrice}) as revenue
      FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY strftime('%Y-%m', ${DatabaseConstants.columnConsultationDate})
      ORDER BY month
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, double> revenueByMonth = {};
    for (final row in result) {
      revenueByMonth[row['month'] as String] = (row['revenue'] as num).toDouble();
    }

    return revenueByMonth;
  }

  // Get total revenue
  Future<double> getTotalRevenue() async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT SUM(${DatabaseConstants.columnConsultationPrice}) as total_revenue FROM ${DatabaseConstants.consultationsTable}',
    );

    if (result.isNotEmpty && result.first['total_revenue'] != null) {
      return (result.first['total_revenue'] as num).toDouble();
    }
    return 0.0;
  }

  // Get total revenue by date range
  Future<double> getTotalRevenueInDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;

    // Get total revenue with date filter
    final result = await db.rawQuery('''
      SELECT SUM(${DatabaseConstants.columnConsultationPrice}) as total_revenue
      FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
        AND ${DatabaseConstants.columnConsultationPrice} IS NOT NULL
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    if (result.isNotEmpty && result.first['total_revenue'] != null) {
      return (result.first['total_revenue'] as num).toDouble();
    }
    return 0.0;
  }

  // Get consultations count by date range
  Future<int> getConsultationsInDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get consultations by day (for chart)
  Future<Map<String, int>> getConsultationsByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT DATE(${DatabaseConstants.columnConsultationDate}) as date,
             COUNT(*) as count
      FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY DATE(${DatabaseConstants.columnConsultationDate})
      ORDER BY date
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, int> consultationsByDay = {};
    for (final row in result) {
      consultationsByDay[row['date'] as String] = row['count'] as int;
    }

    return consultationsByDay;
  }

  // Get filtered statistics with date range
  Future<Map<String, int>> getMostFrequentSymptomsInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT s.${DatabaseConstants.columnSymptomName} as symptom, COUNT(*) as count
      FROM ${DatabaseConstants.symptomsTable} s
      INNER JOIN ${DatabaseConstants.consultationSymptomsTable} cs
        ON s.${DatabaseConstants.columnId} = cs.${DatabaseConstants.columnJunctionSymptomId}
      INNER JOIN ${DatabaseConstants.consultationsTable} c
        ON cs.${DatabaseConstants.columnJunctionConsultationId} = c.${DatabaseConstants.columnId}
      WHERE DATE(c.${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY s.${DatabaseConstants.columnSymptomName}
      ORDER BY count DESC
      LIMIT ?
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
      limit,
    ]);

    final Map<String, int> symptoms = {};
    for (final row in result) {
      symptoms[row['symptom'] as String] = row['count'] as int;
    }

    return symptoms;
  }

  // Get medications prescribed in date range
  Future<Map<String, int>> getMostPrescribedMedicationsInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT m.${DatabaseConstants.columnMedicationName} as medication, COUNT(*) as count
      FROM ${DatabaseConstants.medicationsTable} m
      INNER JOIN ${DatabaseConstants.consultationsTable} c
        ON m.${DatabaseConstants.columnMedicationConsultationId} = c.${DatabaseConstants.columnId}
      WHERE DATE(c.${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY m.${DatabaseConstants.columnMedicationName}
      ORDER BY count DESC
      LIMIT ?
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
      limit,
    ]);

    final Map<String, int> medications = {};
    for (final row in result) {
      medications[row['medication'] as String] = row['count'] as int;
    }

    return medications;
  }

  // Get diagnoses in date range
  Future<Map<String, int>> getMostCommonDiagnosesInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT d.${DatabaseConstants.columnDiagnosisName} as diagnosis, COUNT(*) as count
      FROM ${DatabaseConstants.diagnosesTable} d
      INNER JOIN ${DatabaseConstants.consultationDiagnosesTable} cd
        ON d.${DatabaseConstants.columnId} = cd.${DatabaseConstants.columnJunctionDiagnosisId}
      INNER JOIN ${DatabaseConstants.consultationsTable} c
        ON cd.${DatabaseConstants.columnJunctionConsultationId} = c.${DatabaseConstants.columnId}
      WHERE DATE(c.${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY d.${DatabaseConstants.columnDiagnosisName}
      ORDER BY count DESC
      LIMIT ?
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
      limit,
    ]);

    final Map<String, int> diagnoses = {};
    for (final row in result) {
      diagnoses[row['diagnosis'] as String] = row['count'] as int;
    }

    return diagnoses;
  }

  // Get most frequent patients (patients with most consultations)
  Future<Map<String, int>> getMostFrequentPatientsInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT p.${DatabaseConstants.columnPatientName} as patient_name, COUNT(*) as count
      FROM ${DatabaseConstants.patientsTable} p
      INNER JOIN ${DatabaseConstants.consultationsTable} c
        ON p.${DatabaseConstants.columnId} = c.${DatabaseConstants.columnConsultationPatientId}
      WHERE DATE(c.${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY p.${DatabaseConstants.columnId}, p.${DatabaseConstants.columnPatientName}
      ORDER BY count DESC
      LIMIT ?
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
      limit,
    ]);

    final Map<String, int> patients = {};
    for (final row in result) {
      patients[row['patient_name'] as String] = row['count'] as int;
    }

    return patients;
  }

  // Get weight evolution for recurring patients
  Future<Map<String, List<Map<String, dynamic>>>> getRecurringPatientsWeightEvolution({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;

    // First, get patients with more than one consultation in the date range
    final recurringPatientsResult = await db.rawQuery('''
      SELECT p.${DatabaseConstants.columnId} as patient_id,
             p.${DatabaseConstants.columnPatientName} as patient_name,
             COUNT(c.${DatabaseConstants.columnId}) as consultation_count
      FROM ${DatabaseConstants.patientsTable} p
      INNER JOIN ${DatabaseConstants.consultationsTable} c
        ON p.${DatabaseConstants.columnId} = c.${DatabaseConstants.columnConsultationPatientId}
      WHERE DATE(c.${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
        AND c.${DatabaseConstants.columnConsultationWeight} IS NOT NULL
      GROUP BY p.${DatabaseConstants.columnId}, p.${DatabaseConstants.columnPatientName}
      HAVING COUNT(c.${DatabaseConstants.columnId}) > 1
      ORDER BY consultation_count DESC
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, List<Map<String, dynamic>>> patientsWeightEvolution = {};

    // For each recurring patient, get their weight evolution
    for (final patientRow in recurringPatientsResult) {
      final patientId = patientRow['patient_id'] as int;
      final patientName = patientRow['patient_name'] as String;

      final weightHistoryResult = await db.rawQuery('''
        SELECT DATE(${DatabaseConstants.columnConsultationDate}) as date,
               ${DatabaseConstants.columnConsultationWeight} as weight
        FROM ${DatabaseConstants.consultationsTable}
        WHERE ${DatabaseConstants.columnConsultationPatientId} = ?
          AND DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
          AND ${DatabaseConstants.columnConsultationWeight} IS NOT NULL
        ORDER BY ${DatabaseConstants.columnConsultationDate}
      ''', [
        patientId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ]);

      final List<Map<String, dynamic>> weightHistory = [];
      for (final weightRow in weightHistoryResult) {
        weightHistory.add({
          'date': weightRow['date'] as String,
          'weight': double.parse(((weightRow['weight'] as num).toDouble()).toStringAsFixed(1)),
        });
      }

      if (weightHistory.isNotEmpty) {
        patientsWeightEvolution[patientName] = weightHistory;
      }
    }

    return patientsWeightEvolution;
  }

  // Get symptoms vs diagnoses correlation
  Future<Map<String, Map<String, int>>> getSymptomsVsDiagnosesCorrelation({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT
        s.${DatabaseConstants.columnSymptomName} as symptom,
        d.${DatabaseConstants.columnDiagnosisName} as diagnosis,
        COUNT(*) as correlation_count
      FROM ${DatabaseConstants.consultationsTable} c
      INNER JOIN ${DatabaseConstants.consultationSymptomsTable} cs
        ON c.${DatabaseConstants.columnId} = cs.${DatabaseConstants.columnJunctionConsultationId}
      INNER JOIN ${DatabaseConstants.symptomsTable} s
        ON cs.${DatabaseConstants.columnJunctionSymptomId} = s.${DatabaseConstants.columnId}
      INNER JOIN ${DatabaseConstants.consultationDiagnosesTable} cd
        ON c.${DatabaseConstants.columnId} = cd.${DatabaseConstants.columnJunctionConsultationId}
      INNER JOIN ${DatabaseConstants.diagnosesTable} d
        ON cd.${DatabaseConstants.columnJunctionDiagnosisId} = d.${DatabaseConstants.columnId}
      WHERE DATE(c.${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY s.${DatabaseConstants.columnSymptomName}, d.${DatabaseConstants.columnDiagnosisName}
      ORDER BY correlation_count DESC
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, Map<String, int>> correlation = {};
    for (final row in result) {
      final symptom = row['symptom'] as String;
      final diagnosis = row['diagnosis'] as String;
      final count = row['correlation_count'] as int;

      if (!correlation.containsKey(symptom)) {
        correlation[symptom] = {};
      }
      correlation[symptom]![diagnosis] = count;
    }

    return correlation;
  }

  // New flexible methods for consultations by period
  Future<Map<String, int>> getConsultationsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy, // 'day', 'week', 'month', 'year'
  }) async {
    final db = await _database;

    String groupByClause;

    switch (groupBy) {
      case 'day':
        groupByClause = 'DATE(${DatabaseConstants.columnConsultationDate})';
        break;
      case 'week':
        groupByClause = 'strftime("%Y-W%W", ${DatabaseConstants.columnConsultationDate})';
        break;
      case 'month':
        groupByClause = 'strftime("%Y-%m", ${DatabaseConstants.columnConsultationDate})';
        break;
      case 'year':
        groupByClause = 'strftime("%Y", ${DatabaseConstants.columnConsultationDate})';
        break;
      default:
        throw ArgumentError('Invalid groupBy value: $groupBy');
    }

    final result = await db.rawQuery('''
      SELECT $groupByClause as period,
             COUNT(*) as count
      FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
      GROUP BY $groupByClause
      ORDER BY period
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, int> consultationsByPeriod = {};
    for (final row in result) {
      final period = row['period'] as String;
      final count = row['count'] as int;
      consultationsByPeriod[period] = count;
    }

    return consultationsByPeriod;
  }

  // New flexible methods for revenue by period
  Future<Map<String, double>> getRevenueByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy, // 'day', 'week', 'month', 'year'
  }) async {
    final db = await _database;

    String groupByClause;

    switch (groupBy) {
      case 'day':
        groupByClause = 'DATE(${DatabaseConstants.columnConsultationDate})';
        break;
      case 'week':
        groupByClause = 'strftime("%Y-W%W", ${DatabaseConstants.columnConsultationDate})';
        break;
      case 'month':
        groupByClause = 'strftime("%Y-%m", ${DatabaseConstants.columnConsultationDate})';
        break;
      case 'year':
        groupByClause = 'strftime("%Y", ${DatabaseConstants.columnConsultationDate})';
        break;
      default:
        throw ArgumentError('Invalid groupBy value: $groupBy');
    }

    final result = await db.rawQuery('''
      SELECT $groupByClause as period,
             SUM(${DatabaseConstants.columnConsultationPrice}) as revenue
      FROM ${DatabaseConstants.consultationsTable}
      WHERE DATE(${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
        AND ${DatabaseConstants.columnConsultationPrice} IS NOT NULL
      GROUP BY $groupByClause
      ORDER BY period
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    final Map<String, double> revenueByPeriod = {};
    for (final row in result) {
      final period = row['period'] as String;
      final revenue = (row['revenue'] as num?)?.toDouble() ?? 0.0;
      revenueByPeriod[period] = revenue;
    }

    return revenueByPeriod;
  }

  // Get diagnoses grouped by month for seasonal analysis
  Future<Map<int, Map<String, int>>> getDiagnosesByMonth({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _database;

      final result = await db.rawQuery('''
        SELECT strftime("%m", c.${DatabaseConstants.columnConsultationDate}) as month,
               d.${DatabaseConstants.columnDiagnosisName} as diagnosis,
               COUNT(*) as count
        FROM ${DatabaseConstants.consultationsTable} c
        INNER JOIN ${DatabaseConstants.consultationDiagnosesTable} cd
          ON c.${DatabaseConstants.columnId} = cd.${DatabaseConstants.columnJunctionConsultationId}
        INNER JOIN ${DatabaseConstants.diagnosesTable} d
          ON cd.${DatabaseConstants.columnJunctionDiagnosisId} = d.${DatabaseConstants.columnId}
        WHERE DATE(c.${DatabaseConstants.columnConsultationDate}) BETWEEN ? AND ?
        GROUP BY month, diagnosis
        ORDER BY month, count DESC
      ''', [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ]);

      final Map<int, Map<String, int>> monthlyDiagnoses = {};

      if (result.isNotEmpty) {
        for (final row in result) {
          final monthStr = row['month'] as String?;
          final diagnosis = row['diagnosis'] as String?;
          final count = row['count'] as int?;

          if (monthStr != null && diagnosis != null && count != null) {
            final month = int.parse(monthStr);
            monthlyDiagnoses[month] ??= <String, int>{};
            monthlyDiagnoses[month]![diagnosis] = count;
          }
        }
      }

      return monthlyDiagnoses;
    } catch (e) {
      // Return empty map on any error to prevent null issues
      return <int, Map<String, int>>{};
    }
  }

  // Get patient age demographics
  Future<Map<String, int>> getPatientAgeDemographics() async {
    try {
      final db = await _database;

      final result = await db.rawQuery('''
        SELECT ${DatabaseConstants.columnPatientAge} as age
        FROM ${DatabaseConstants.patientsTable}
        WHERE ${DatabaseConstants.columnPatientAge} IS NOT NULL
      ''');

      final Map<String, int> ageDemographics = {
        'Primera infancia (0-5)': 0,
        'Infancia (6-11)': 0,
        'Adolescencia (12-18)': 0,
        'Juventud (19-26)': 0,
        'Adultez (27-59)': 0,
        'Vejez (60+)': 0,
      };

      for (final row in result) {
        final age = row['age'] as int?;
        if (age != null) {
          final category = _getAgeCategory(age);
          ageDemographics[category] = (ageDemographics[category] ?? 0) + 1;
        }
      }

      return ageDemographics;
    } catch (e) {
      // Return empty map on any error to prevent null issues
      return <String, int>{
        'Primera infancia (0-5)': 0,
        'Infancia (6-11)': 0,
        'Adolescencia (12-18)': 0,
        'Juventud (19-26)': 0,
        'Adultez (27-59)': 0,
        'Vejez (60+)': 0,
      };
    }
  }

  String _getAgeCategory(int age) {
    if (age >= 0 && age <= 5) {
      return 'Primera infancia (0-5)';
    } else if (age >= 6 && age <= 11) {
      return 'Infancia (6-11)';
    } else if (age >= 12 && age <= 18) {
      return 'Adolescencia (12-18)';
    } else if (age >= 19 && age <= 26) {
      return 'Juventud (19-26)';
    } else if (age >= 27 && age <= 59) {
      return 'Adultez (27-59)';
    } else {
      return 'Vejez (60+)';
    }
  }
}