import 'package:sqflite/sqflite.dart';
import 'package:doctor_app/data/database/database_helper.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/core/constants/database_constants.dart';

class PatientRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _database async => await _databaseHelper.database;

  // Create - Insert a new patient
  Future<int> insertPatient(Patient patient) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    final patientMap = {
      DatabaseConstants.columnPatientName: patient.name,
      DatabaseConstants.columnPatientAge: patient.age,
      DatabaseConstants.columnPatientBirthDate: patient.birthDate.toIso8601String(),
      DatabaseConstants.columnPatientPhone: patient.phone,
      DatabaseConstants.columnPatientEmail: patient.email,
      DatabaseConstants.columnPatientGender: patient.gender,
      DatabaseConstants.columnCreatedAt: now,
      DatabaseConstants.columnUpdatedAt: now,
    };

    return await db.insert(
      DatabaseConstants.patientsTable,
      patientMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read - Get all patients
  Future<List<Patient>> getAllPatients() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.patientsTable,
      orderBy: '${DatabaseConstants.columnCreatedAt} DESC',
    );

    return List.generate(maps.length, (i) {
      final dbMap = maps[i];
      return Patient(
        id: dbMap[DatabaseConstants.columnId],
        name: dbMap[DatabaseConstants.columnPatientName],
        age: dbMap[DatabaseConstants.columnPatientAge],
        birthDate: DateTime.parse(dbMap[DatabaseConstants.columnPatientBirthDate]),
        phone: dbMap[DatabaseConstants.columnPatientPhone],
        email: dbMap[DatabaseConstants.columnPatientEmail],
        gender: dbMap[DatabaseConstants.columnPatientGender],
        createdAt: DateTime.parse(dbMap[DatabaseConstants.columnCreatedAt]),
      );
    });
  }

  // Read - Get patient by ID
  Future<Patient?> getPatientById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.patientsTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final dbMap = maps.first;
      return Patient(
        id: dbMap[DatabaseConstants.columnId],
        name: dbMap[DatabaseConstants.columnPatientName],
        age: dbMap[DatabaseConstants.columnPatientAge],
        birthDate: DateTime.parse(dbMap[DatabaseConstants.columnPatientBirthDate]),
        phone: dbMap[DatabaseConstants.columnPatientPhone],
        email: dbMap[DatabaseConstants.columnPatientEmail],
        gender: dbMap[DatabaseConstants.columnPatientGender],
        createdAt: DateTime.parse(dbMap[DatabaseConstants.columnCreatedAt]),
      );
    }
    return null;
  }

  // Read - Search patients by name
  Future<List<Patient>> searchPatientsByName(String searchTerm) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.patientsTable,
      where: '${DatabaseConstants.columnPatientName} LIKE ?',
      whereArgs: ['%$searchTerm%'],
      orderBy: '${DatabaseConstants.columnPatientName} ASC',
    );

    return List.generate(maps.length, (i) {
      final dbMap = maps[i];
      return Patient(
        id: dbMap[DatabaseConstants.columnId],
        name: dbMap[DatabaseConstants.columnPatientName],
        age: dbMap[DatabaseConstants.columnPatientAge],
        birthDate: DateTime.parse(dbMap[DatabaseConstants.columnPatientBirthDate]),
        phone: dbMap[DatabaseConstants.columnPatientPhone],
        email: dbMap[DatabaseConstants.columnPatientEmail],
        gender: dbMap[DatabaseConstants.columnPatientGender],
        createdAt: DateTime.parse(dbMap[DatabaseConstants.columnCreatedAt]),
      );
    });
  }

  // Update - Update existing patient
  Future<int> updatePatient(Patient patient) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    final patientMap = {
      DatabaseConstants.columnPatientName: patient.name,
      DatabaseConstants.columnPatientAge: patient.age,
      DatabaseConstants.columnPatientBirthDate: patient.birthDate.toIso8601String(),
      DatabaseConstants.columnPatientPhone: patient.phone,
      DatabaseConstants.columnPatientEmail: patient.email,
      DatabaseConstants.columnPatientGender: patient.gender,
      DatabaseConstants.columnUpdatedAt: now,
    };

    return await db.update(
      DatabaseConstants.patientsTable,
      patientMap,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [patient.id],
    );
  }

  // Delete - Delete patient by ID
  Future<int> deletePatient(int id) async {
    final db = await _database;
    return await db.delete(
      DatabaseConstants.patientsTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Get patient count
  Future<int> getPatientCount() async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseConstants.patientsTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get patients with pagination
  Future<List<Patient>> getPatientsWithPagination({
    required int offset,
    required int limit,
  }) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.patientsTable,
      orderBy: '${DatabaseConstants.columnCreatedAt} DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      final dbMap = maps[i];
      return Patient(
        id: dbMap[DatabaseConstants.columnId],
        name: dbMap[DatabaseConstants.columnPatientName],
        age: dbMap[DatabaseConstants.columnPatientAge],
        birthDate: DateTime.parse(dbMap[DatabaseConstants.columnPatientBirthDate]),
        phone: dbMap[DatabaseConstants.columnPatientPhone],
        email: dbMap[DatabaseConstants.columnPatientEmail],
        gender: dbMap[DatabaseConstants.columnPatientGender],
        createdAt: DateTime.parse(dbMap[DatabaseConstants.columnCreatedAt]),
      );
    });
  }

  // Check if patient exists by phone
  Future<bool> patientExistsByPhone(String phone, {int? excludeId}) async {
    final db = await _database;
    String whereClause = '${DatabaseConstants.columnPatientPhone} = ?';
    List<dynamic> whereArgs = [phone];

    if (excludeId != null) {
      whereClause += ' AND ${DatabaseConstants.columnId} != ?';
      whereArgs.add(excludeId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.patientsTable,
      where: whereClause,
      whereArgs: whereArgs,
    );

    return maps.isNotEmpty;
  }
}