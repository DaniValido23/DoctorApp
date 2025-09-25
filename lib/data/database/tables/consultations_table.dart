import 'package:doctor_app/core/constants/database_constants.dart';

class ConsultationsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.consultationsTable} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnConsultationPatientId} INTEGER NOT NULL,
      ${DatabaseConstants.columnConsultationDate} TEXT NOT NULL,
      -- Vital Signs (all optional)
      ${DatabaseConstants.columnConsultationBodyTemperature} REAL,
      ${DatabaseConstants.columnConsultationBloodPressureSystolic} INTEGER,
      ${DatabaseConstants.columnConsultationBloodPressureDiastolic} INTEGER,
      ${DatabaseConstants.columnConsultationOxygenSaturation} REAL,
      ${DatabaseConstants.columnConsultationWeight} REAL,
      ${DatabaseConstants.columnConsultationHeight} REAL,
      -- Other fields
      ${DatabaseConstants.columnConsultationObservations} TEXT,
      ${DatabaseConstants.columnConsultationPrice} REAL NOT NULL,
      ${DatabaseConstants.columnConsultationPdfPath} TEXT,
      ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseConstants.columnUpdatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseConstants.columnConsultationPatientId})
        REFERENCES ${DatabaseConstants.patientsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.consultationsTable}
  ''';
}