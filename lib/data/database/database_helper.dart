import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:doctor_app/core/constants/database_constants.dart';
import 'package:doctor_app/data/database/tables/patients_table.dart';
import 'package:doctor_app/data/database/tables/consultations_table.dart';
import 'package:doctor_app/data/database/tables/medications_table.dart';
import 'package:doctor_app/data/database/tables/symptoms_table.dart';
import 'package:doctor_app/data/database/tables/treatments_table.dart';
import 'package:doctor_app/data/database/tables/diagnoses_table.dart';
import 'package:doctor_app/data/database/tables/attachments_table.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Create main tables
    batch.execute(PatientsTable.createTable);
    batch.execute(ConsultationsTable.createTable);
    batch.execute(MedicationsTable.createTable);
    batch.execute(SymptomsTable.createTable);
    batch.execute(TreatmentsTable.createTable);
    batch.execute(DiagnosesTable.createTable);
    batch.execute(AttachmentsTable.createTable);

    // Create junction tables
    batch.execute(ConsultationSymptomsTable.createTable);
    batch.execute(ConsultationTreatmentsTable.createTable);
    batch.execute(ConsultationDiagnosesTable.createTable);

    await batch.commit();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed in the future
    if (oldVersion < newVersion) {
      // For now, we'll recreate all tables
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _dropAllTables(Database db) async {
    final batch = db.batch();

    // Drop junction tables first (due to foreign keys)
    batch.execute(ConsultationSymptomsTable.dropTable);
    batch.execute(ConsultationTreatmentsTable.dropTable);
    batch.execute(ConsultationDiagnosesTable.dropTable);

    // Drop main tables
    batch.execute(AttachmentsTable.dropTable);
    batch.execute(MedicationsTable.dropTable);
    batch.execute(ConsultationsTable.dropTable);
    batch.execute(SymptomsTable.dropTable);
    batch.execute(TreatmentsTable.dropTable);
    batch.execute(DiagnosesTable.dropTable);
    batch.execute(PatientsTable.dropTable);

    await batch.commit();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Transaction helper
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
}