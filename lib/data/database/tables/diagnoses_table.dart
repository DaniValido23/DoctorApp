import 'package:doctor_app/core/constants/database_constants.dart';

class DiagnosesTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.diagnosesTable} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnDiagnosisName} TEXT NOT NULL UNIQUE,
      ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.diagnosesTable}
  ''';
}

class ConsultationDiagnosesTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.consultationDiagnosesTable} (
      ${DatabaseConstants.columnJunctionConsultationId} INTEGER NOT NULL,
      ${DatabaseConstants.columnJunctionDiagnosisId} INTEGER NOT NULL,
      PRIMARY KEY (${DatabaseConstants.columnJunctionConsultationId}, ${DatabaseConstants.columnJunctionDiagnosisId}),
      FOREIGN KEY (${DatabaseConstants.columnJunctionConsultationId})
        REFERENCES ${DatabaseConstants.consultationsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE,
      FOREIGN KEY (${DatabaseConstants.columnJunctionDiagnosisId})
        REFERENCES ${DatabaseConstants.diagnosesTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.consultationDiagnosesTable}
  ''';
}