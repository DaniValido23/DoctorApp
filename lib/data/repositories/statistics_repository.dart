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

  // Get revenue by period
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
      'SELECT SUM(${DatabaseConstants.columnConsultationPrice}) FROM ${DatabaseConstants.consultationsTable}',
    );
    return (Sqflite.firstIntValue(result) ?? 0).toDouble();
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
}