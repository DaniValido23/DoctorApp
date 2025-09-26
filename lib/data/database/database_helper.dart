import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:doctor_app/core/constants/database_constants.dart';
import 'package:doctor_app/data/database/tables/tables.dart';

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
    batch.execute(DiagnosesTable.createTable);
    batch.execute(AttachmentsTable.createTable);

    // Create junction tables
    batch.execute(ConsultationSymptomsTable.createTable);
    batch.execute(ConsultationDiagnosesTable.createTable);

    await batch.commit();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades preserving existing data
    if (oldVersion < 3 && newVersion >= 3) {
      await _upgradeToV3(db);
    }

    // Future upgrades can be added here
    // if (oldVersion < 4 && newVersion >= 4) {
    //   await _upgradeToV4(db);
    // }
  }

  Future<void> _upgradeToV3(Database db) async {
    // Add vital signs columns to consultations table
    await db.execute('''
      ALTER TABLE ${DatabaseConstants.consultationsTable}
      ADD COLUMN ${DatabaseConstants.columnConsultationBodyTemperature} REAL
    ''');

    await db.execute('''
      ALTER TABLE ${DatabaseConstants.consultationsTable}
      ADD COLUMN ${DatabaseConstants.columnConsultationBloodPressureSystolic} INTEGER
    ''');

    await db.execute('''
      ALTER TABLE ${DatabaseConstants.consultationsTable}
      ADD COLUMN ${DatabaseConstants.columnConsultationBloodPressureDiastolic} INTEGER
    ''');

    await db.execute('''
      ALTER TABLE ${DatabaseConstants.consultationsTable}
      ADD COLUMN ${DatabaseConstants.columnConsultationOxygenSaturation} REAL
    ''');

    await db.execute('''
      ALTER TABLE ${DatabaseConstants.consultationsTable}
      ADD COLUMN ${DatabaseConstants.columnConsultationHeight} REAL
    ''');

    // Make weight column nullable by creating new table structure
    // Note: SQLite doesn't support ALTER COLUMN, so we'd need to recreate table
    // For now, we'll keep weight as NOT NULL but handle nulls in application logic
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