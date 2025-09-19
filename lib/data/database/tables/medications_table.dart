import 'package:doctor_app/core/constants/database_constants.dart';

class MedicationsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.medicationsTable} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnMedicationConsultationId} INTEGER NOT NULL,
      ${DatabaseConstants.columnMedicationName} TEXT NOT NULL,
      ${DatabaseConstants.columnMedicationDosage} TEXT NOT NULL,
      ${DatabaseConstants.columnMedicationFrequency} TEXT NOT NULL,
      ${DatabaseConstants.columnMedicationInstructions} TEXT,
      ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseConstants.columnMedicationConsultationId})
        REFERENCES ${DatabaseConstants.consultationsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.medicationsTable}
  ''';
}