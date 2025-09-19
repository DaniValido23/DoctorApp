import 'package:doctor_app/core/constants/database_constants.dart';

class PatientsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.patientsTable} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnPatientName} TEXT NOT NULL,
      ${DatabaseConstants.columnPatientAge} INTEGER NOT NULL,
      ${DatabaseConstants.columnPatientBirthDate} TEXT NOT NULL,
      ${DatabaseConstants.columnPatientPhone} TEXT NOT NULL,
      ${DatabaseConstants.columnPatientEmail} TEXT,
      ${DatabaseConstants.columnPatientGender} TEXT NOT NULL,
      ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseConstants.columnUpdatedAt} TEXT NOT NULL
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.patientsTable}
  ''';
}