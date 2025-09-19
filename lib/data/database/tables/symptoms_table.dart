import 'package:doctor_app/core/constants/database_constants.dart';

class SymptomsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.symptomsTable} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnSymptomName} TEXT NOT NULL UNIQUE,
      ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.symptomsTable}
  ''';
}

class ConsultationSymptomsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.consultationSymptomsTable} (
      ${DatabaseConstants.columnJunctionConsultationId} INTEGER NOT NULL,
      ${DatabaseConstants.columnJunctionSymptomId} INTEGER NOT NULL,
      PRIMARY KEY (${DatabaseConstants.columnJunctionConsultationId}, ${DatabaseConstants.columnJunctionSymptomId}),
      FOREIGN KEY (${DatabaseConstants.columnJunctionConsultationId})
        REFERENCES ${DatabaseConstants.consultationsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE,
      FOREIGN KEY (${DatabaseConstants.columnJunctionSymptomId})
        REFERENCES ${DatabaseConstants.symptomsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.consultationSymptomsTable}
  ''';
}