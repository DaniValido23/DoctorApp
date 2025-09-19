import 'package:doctor_app/core/constants/database_constants.dart';

class AttachmentsTable {
  static const String createTable = '''
    CREATE TABLE ${DatabaseConstants.attachmentsTable} (
      ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.columnAttachmentConsultationId} INTEGER NOT NULL,
      ${DatabaseConstants.columnAttachmentFileName} TEXT NOT NULL,
      ${DatabaseConstants.columnAttachmentFilePath} TEXT NOT NULL,
      ${DatabaseConstants.columnAttachmentFileType} TEXT NOT NULL,
      ${DatabaseConstants.columnAttachmentUploadedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseConstants.columnAttachmentConsultationId})
        REFERENCES ${DatabaseConstants.consultationsTable}(${DatabaseConstants.columnId})
        ON DELETE CASCADE
    )
  ''';

  static const String dropTable = '''
    DROP TABLE IF EXISTS ${DatabaseConstants.attachmentsTable}
  ''';
}