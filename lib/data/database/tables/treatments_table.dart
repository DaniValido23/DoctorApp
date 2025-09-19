import 'package:doctor_app/core/constants/database_constants.dart';

class TreatmentsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.treatmentsTable} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnTreatmentName} TEXT NOT NULL UNIQUE,
      ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.treatmentsTable}
  ''';
}

class ConsultationTreatmentsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.consultationTreatmentsTable} (
      ${DatabaseConstants.columnJunctionConsultationId} INTEGER NOT NULL,
      ${DatabaseConstants.columnJunctionTreatmentId} INTEGER NOT NULL,
      PRIMARY KEY (${DatabaseConstants.columnJunctionConsultationId}, ${DatabaseConstants.columnJunctionTreatmentId}),
      FOREIGN KEY (${DatabaseConstants.columnJunctionConsultationId})
        REFERENCES ${DatabaseConstants.consultationsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE,
      FOREIGN KEY (${DatabaseConstants.columnJunctionTreatmentId})
        REFERENCES ${DatabaseConstants.treatmentsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.consultationTreatmentsTable}
  ''';
}