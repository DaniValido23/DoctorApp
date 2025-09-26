import 'package:sqflite/sqflite.dart';
import 'package:doctor_app/data/database/database_helper.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/core/constants/database_constants.dart';

class ConsultationRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _database async => await _databaseHelper.database;

  // Create - Insert a new consultation
  Future<int> insertConsultation(Consultation consultation) async {
    return await _databaseHelper.transaction((txn) async {
      final now = DateTime.now().toIso8601String();

      // Insert consultation
      final consultationMap = {
        DatabaseConstants.columnConsultationPatientId: consultation.patientId,
        DatabaseConstants.columnConsultationDate: consultation.date.toIso8601String(),
        // Vital Signs
        DatabaseConstants.columnConsultationBodyTemperature: consultation.bodyTemperature,
        DatabaseConstants.columnConsultationBloodPressureSystolic: consultation.bloodPressureSystolic,
        DatabaseConstants.columnConsultationBloodPressureDiastolic: consultation.bloodPressureDiastolic,
        DatabaseConstants.columnConsultationOxygenSaturation: consultation.oxygenSaturation,
        DatabaseConstants.columnConsultationWeight: consultation.weight,
        DatabaseConstants.columnConsultationHeight: consultation.height,
        // Other fields
        DatabaseConstants.columnConsultationObservations: consultation.observations,
        DatabaseConstants.columnConsultationPrice: consultation.price,
        DatabaseConstants.columnConsultationPdfPath: consultation.pdfPath,
        DatabaseConstants.columnCreatedAt: now,
        DatabaseConstants.columnUpdatedAt: now,
      };

      final consultationId = await txn.insert(
        DatabaseConstants.consultationsTable,
        consultationMap,
      );

      // Insert symptoms
      await _insertSymptoms(txn, consultationId, consultation.symptoms);

      // Insert diagnoses
      await _insertDiagnoses(txn, consultationId, consultation.diagnoses);

      // Insert medications
      for (final medication in consultation.medications) {
        await _insertMedication(txn, consultationId, medication);
      }

      // Insert attachments
      for (final attachment in consultation.attachments) {
        await _insertAttachment(txn, consultationId, attachment);
      }

      return consultationId;
    });
  }

  // Read - Get consultation by ID
  Future<Consultation?> getConsultationById(int id) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.consultationsTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final consultationMap = maps.first;

    // Get related data
    final symptoms = await _getConsultationSymptoms(db, id);
    final diagnoses = await _getConsultationDiagnoses(db, id);
    final medications = await _getConsultationMedications(db, id);
    final attachments = await _getConsultationAttachments(db, id);

    return Consultation(
      id: consultationMap[DatabaseConstants.columnId],
      patientId: consultationMap[DatabaseConstants.columnConsultationPatientId],
      date: DateTime.parse(consultationMap[DatabaseConstants.columnConsultationDate]),
      // Vital Signs
      bodyTemperature: consultationMap[DatabaseConstants.columnConsultationBodyTemperature]?.toDouble(),
      bloodPressureSystolic: consultationMap[DatabaseConstants.columnConsultationBloodPressureSystolic],
      bloodPressureDiastolic: consultationMap[DatabaseConstants.columnConsultationBloodPressureDiastolic],
      oxygenSaturation: consultationMap[DatabaseConstants.columnConsultationOxygenSaturation]?.toDouble(),
      weight: consultationMap[DatabaseConstants.columnConsultationWeight]?.toDouble(),
      height: consultationMap[DatabaseConstants.columnConsultationHeight]?.toDouble(),
      // Medical Information
      symptoms: symptoms,
      diagnoses: diagnoses,
      medications: medications,
      attachments: attachments,
      observations: consultationMap[DatabaseConstants.columnConsultationObservations],
      price: consultationMap[DatabaseConstants.columnConsultationPrice],
      pdfPath: consultationMap[DatabaseConstants.columnConsultationPdfPath],
    );
  }

  // Read - Get consultations by patient ID
  Future<List<Consultation>> getConsultationsByPatientId(int patientId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.consultationsTable,
      where: '${DatabaseConstants.columnConsultationPatientId} = ?',
      whereArgs: [patientId],
      orderBy: '${DatabaseConstants.columnConsultationDate} DESC',
    );

    final consultations = <Consultation>[];
    for (final map in maps) {
      final consultation = await getConsultationById(map[DatabaseConstants.columnId]);
      if (consultation != null) {
        consultations.add(consultation);
      }
    }

    return consultations;
  }

  // Helper methods for inserting related data
  Future<void> _insertSymptoms(Transaction txn, int consultationId, List<String> symptoms) async {
    for (final symptomName in symptoms) {
      // Insert or get symptom ID
      final symptomId = await _getOrInsertSymptom(txn, symptomName);

      // Insert junction record
      await txn.insert(
        DatabaseConstants.consultationSymptomsTable,
        {
          DatabaseConstants.columnJunctionConsultationId: consultationId,
          DatabaseConstants.columnJunctionSymptomId: symptomId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }


  Future<void> _insertDiagnoses(Transaction txn, int consultationId, List<String> diagnoses) async {
    for (final diagnosisName in diagnoses) {
      // Insert or get diagnosis ID
      final diagnosisId = await _getOrInsertDiagnosis(txn, diagnosisName);

      // Insert junction record
      await txn.insert(
        DatabaseConstants.consultationDiagnosesTable,
        {
          DatabaseConstants.columnJunctionConsultationId: consultationId,
          DatabaseConstants.columnJunctionDiagnosisId: diagnosisId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _insertMedication(Transaction txn, int consultationId, Medication medication) async {
    await txn.insert(
      DatabaseConstants.medicationsTable,
      {
        DatabaseConstants.columnMedicationConsultationId: consultationId,
        DatabaseConstants.columnMedicationName: medication.name,
        DatabaseConstants.columnMedicationDosage: medication.dosage,
        DatabaseConstants.columnMedicationFrequency: medication.frequency,
        DatabaseConstants.columnMedicationInstructions: medication.instructions,
        DatabaseConstants.columnCreatedAt: DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _insertAttachment(Transaction txn, int consultationId, Attachment attachment) async {
    await txn.insert(
      DatabaseConstants.attachmentsTable,
      {
        DatabaseConstants.columnAttachmentConsultationId: consultationId,
        DatabaseConstants.columnAttachmentFileName: attachment.fileName,
        DatabaseConstants.columnAttachmentFilePath: attachment.filePath,
        DatabaseConstants.columnAttachmentFileType: attachment.fileType,
        DatabaseConstants.columnAttachmentUploadedAt: attachment.uploadedAt.toIso8601String(),
      },
    );
  }

  // Helper methods for getting or inserting master data
  Future<int> _getOrInsertSymptom(Transaction txn, String symptomName) async {
    final result = await txn.query(
      DatabaseConstants.symptomsTable,
      where: '${DatabaseConstants.columnSymptomName} = ?',
      whereArgs: [symptomName],
    );

    if (result.isNotEmpty) {
      return result.first[DatabaseConstants.columnId] as int;
    }

    return await txn.insert(
      DatabaseConstants.symptomsTable,
      {
        DatabaseConstants.columnSymptomName: symptomName,
        DatabaseConstants.columnCreatedAt: DateTime.now().toIso8601String(),
      },
    );
  }


  Future<int> _getOrInsertDiagnosis(Transaction txn, String diagnosisName) async {
    final result = await txn.query(
      DatabaseConstants.diagnosesTable,
      where: '${DatabaseConstants.columnDiagnosisName} = ?',
      whereArgs: [diagnosisName],
    );

    if (result.isNotEmpty) {
      return result.first[DatabaseConstants.columnId] as int;
    }

    return await txn.insert(
      DatabaseConstants.diagnosesTable,
      {
        DatabaseConstants.columnDiagnosisName: diagnosisName,
        DatabaseConstants.columnCreatedAt: DateTime.now().toIso8601String(),
      },
    );
  }

  // Helper methods for getting related data
  Future<List<String>> _getConsultationSymptoms(Database db, int consultationId) async {
    final result = await db.rawQuery('''
      SELECT s.${DatabaseConstants.columnSymptomName}
      FROM ${DatabaseConstants.symptomsTable} s
      INNER JOIN ${DatabaseConstants.consultationSymptomsTable} cs
        ON s.${DatabaseConstants.columnId} = cs.${DatabaseConstants.columnJunctionSymptomId}
      WHERE cs.${DatabaseConstants.columnJunctionConsultationId} = ?
    ''', [consultationId]);

    return result.map((row) => row[DatabaseConstants.columnSymptomName] as String).toList();
  }


  Future<List<String>> _getConsultationDiagnoses(Database db, int consultationId) async {
    final result = await db.rawQuery('''
      SELECT d.${DatabaseConstants.columnDiagnosisName}
      FROM ${DatabaseConstants.diagnosesTable} d
      INNER JOIN ${DatabaseConstants.consultationDiagnosesTable} cd
        ON d.${DatabaseConstants.columnId} = cd.${DatabaseConstants.columnJunctionDiagnosisId}
      WHERE cd.${DatabaseConstants.columnJunctionConsultationId} = ?
    ''', [consultationId]);

    return result.map((row) => row[DatabaseConstants.columnDiagnosisName] as String).toList();
  }

  Future<List<Medication>> _getConsultationMedications(Database db, int consultationId) async {
    final result = await db.query(
      DatabaseConstants.medicationsTable,
      where: '${DatabaseConstants.columnMedicationConsultationId} = ?',
      whereArgs: [consultationId],
    );

    return result.map((row) => Medication(
      id: row[DatabaseConstants.columnId] as int,
      name: row[DatabaseConstants.columnMedicationName] as String,
      dosage: row[DatabaseConstants.columnMedicationDosage] as String,
      frequency: row[DatabaseConstants.columnMedicationFrequency] as String,
      instructions: row[DatabaseConstants.columnMedicationInstructions] as String?,
    )).toList();
  }

  Future<List<Attachment>> _getConsultationAttachments(Database db, int consultationId) async {
    final result = await db.query(
      DatabaseConstants.attachmentsTable,
      where: '${DatabaseConstants.columnAttachmentConsultationId} = ?',
      whereArgs: [consultationId],
    );

    return result.map((row) => Attachment(
      id: row[DatabaseConstants.columnId] as int,
      fileName: row[DatabaseConstants.columnAttachmentFileName] as String,
      filePath: row[DatabaseConstants.columnAttachmentFilePath] as String,
      fileType: row[DatabaseConstants.columnAttachmentFileType] as String,
      uploadedAt: DateTime.parse(row[DatabaseConstants.columnAttachmentUploadedAt] as String),
    )).toList();
  }

  // Update consultation
  Future<void> updateConsultation(Consultation consultation) async {
    final db = await _database;
    await db.update(
      DatabaseConstants.consultationsTable,
      {
        DatabaseConstants.columnConsultationPatientId: consultation.patientId,
        DatabaseConstants.columnConsultationDate: consultation.date.toIso8601String(),
        // Vital Signs
        DatabaseConstants.columnConsultationBodyTemperature: consultation.bodyTemperature,
        DatabaseConstants.columnConsultationBloodPressureSystolic: consultation.bloodPressureSystolic,
        DatabaseConstants.columnConsultationBloodPressureDiastolic: consultation.bloodPressureDiastolic,
        DatabaseConstants.columnConsultationOxygenSaturation: consultation.oxygenSaturation,
        DatabaseConstants.columnConsultationWeight: consultation.weight,
        DatabaseConstants.columnConsultationHeight: consultation.height,
        // Other fields
        DatabaseConstants.columnConsultationObservations: consultation.observations,
        DatabaseConstants.columnConsultationPrice: consultation.price,
        DatabaseConstants.columnConsultationPdfPath: consultation.pdfPath,
        DatabaseConstants.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [consultation.id],
    );
  }

  // Delete consultation
  Future<int> deleteConsultation(int id) async {
    final db = await _database;
    return await db.delete(
      DatabaseConstants.consultationsTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }
}