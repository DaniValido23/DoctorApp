import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:doctor_app/data/database/database_helper.dart';
import 'package:doctor_app/data/database/seed_data.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/core/constants/database_constants.dart';

class DatabaseSeeder {
  final Random _random = Random();

  Future<void> seedDatabase() async {
    // Iniciando seed de la base de datos usando datos estáticos

    try {
      int consultationIdIndex = 0;

      for (final patientData in SeedData.patients) {
        // Crear paciente con ID específico
        final patient = Patient(
          id: patientData['id'],
          name: patientData['name'],
          age: patientData['age'],
          birthDate: DateTime.parse(patientData['birth_date']),
          phone: patientData['phone'],
          email: patientData['email'],
          gender: patientData['gender'],
          createdAt: DateTime.now(),
        );

        // Insertar paciente con ID específico para seeding
        final newPatientId = await _insertPatientWithSpecificId(patient);

        // Crear consultas para este paciente
        final originalPatientId = patientData['id'] as int;
        final numConsultations = SeedData.consultationsPerPatient[originalPatientId]!;

        for (int j = 0; j < numConsultations; j++) {
          final consultationId = SeedData.consultationIds[consultationIdIndex];
          final consultation = _generateConsultationForPatient(
            consultationId,
            newPatientId, // Usar el ID real del paciente insertado
            j,
            numConsultations,
            originalPatientId - 1000 // Usar el índice original para datos consistentes
          );
          await _insertConsultationWithSpecificId(consultation);
          consultationIdIndex++;
        }
      }

      // Seed completado: 20 pacientes con múltiples consultas creados
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearSeedData() async {
    // Eliminando datos de seed - primero por nombres de pacientes, luego por IDs específicos

    try {
      final db = await DatabaseHelper().database;

      final seedPatientNames = SeedData.patients.map((p) => "'${p['name']}'").join(',');

      final patientResults = await db.rawQuery('''
        SELECT ${DatabaseConstants.columnId} FROM ${DatabaseConstants.patientsTable}
        WHERE ${DatabaseConstants.columnPatientName} IN ($seedPatientNames)
      ''');

      final actualPatientIds = patientResults.map((row) => row[DatabaseConstants.columnId]).toList();

      if (actualPatientIds.isNotEmpty) {
        final patientIdsStr = actualPatientIds.join(',');
        await db.rawDelete('''
          DELETE FROM ${DatabaseConstants.consultationsTable}
          WHERE ${DatabaseConstants.columnConsultationPatientId} IN ($patientIdsStr)
        ''');

        await db.rawDelete('''
          DELETE FROM ${DatabaseConstants.patientsTable}
          WHERE ${DatabaseConstants.columnId} IN ($patientIdsStr)
        ''');
      }

      final consultationIdsStr = SeedData.consultationIds.join(',');
      await db.rawDelete('''
        DELETE FROM ${DatabaseConstants.consultationsTable}
        WHERE ${DatabaseConstants.columnId} IN ($consultationIdsStr)
      ''');

      final patientIdsStr = SeedData.patientIds.join(',');
      await db.rawDelete('''
        DELETE FROM ${DatabaseConstants.patientsTable}
        WHERE ${DatabaseConstants.columnId} IN ($patientIdsStr)
      ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasSeedData() async {
    try {
      final db = await DatabaseHelper().database;

      final seedPatientNames = SeedData.patients.map((p) => "'${p['name']}'").join(',');
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM ${DatabaseConstants.patientsTable}
        WHERE ${DatabaseConstants.columnPatientName} IN ($seedPatientNames)
      ''');

      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Consultation _generateConsultationForPatient(int consultationId, int patientId, int consultationIndex, int totalConsultations, int patientIndex) {
    final now = DateTime.now();

    // Fechas distribuidas en los últimos 6 meses con mejor distribución para múltiples consultas
    late final DateTime consultationDate;

    if (totalConsultations == 1) {
      // Consulta única: cualquier fecha en los últimos 180 días
      final daysAgo = _random.nextInt(180);
      consultationDate = now.subtract(Duration(days: daysAgo));
    } else {
      // Múltiples consultas: distribuir más sistemáticamente
      final maxDaysBack = 180;
      final intervalDays = maxDaysBack ~/ totalConsultations;

      // Calcular rango para esta consulta específica
      final startDay = consultationIndex * intervalDays;
      final endDay = (consultationIndex + 1) * intervalDays;

      // Agregar algo de aleatoriedad dentro del rango
      final randomOffset = _random.nextInt((endDay - startDay).clamp(1, 30));
      final daysAgo = maxDaysBack - (startDay + randomOffset);

      consultationDate = now.subtract(Duration(days: daysAgo.clamp(1, 180)));
    }

    // Peso con evolución realista para múltiples consultas
    late final double weight;

    if (totalConsultations == 1 || consultationIndex == 0) {
      // Primera consulta o consulta única: peso base aleatorio
      weight = double.parse((50.0 + _random.nextDouble() * 70.0).toStringAsFixed(1));
    } else {
      // Consultas subsecuentes: simular evolución de peso realista
      final baseWeight = 50.0 + (patientIndex * 7.0); // Peso base consistente por paciente

      // Tendencia: algunos pacientes bajan peso, otros suben, otros se mantienen
      final trend = (patientIndex % 3) == 0 ? -1.0 : // Bajan peso
                    (patientIndex % 3) == 1 ? 1.0 :   // Suben peso
                    0.0;                              // Se mantienen

      // Variación por tiempo: -2kg a +3kg por mes dependiendo de la tendencia
      final weightChange = trend * (consultationIndex * (0.5 + _random.nextDouble() * 1.5));

      // Agregar algo de variabilidad natural
      final naturalVariation = (_random.nextDouble() - 0.5) * 2.0; // ±1kg

      final calculatedWeight = (baseWeight + weightChange + naturalVariation).clamp(45.0, 130.0);
      weight = double.parse(calculatedWeight.toStringAsFixed(1));
    }

    // Precio aleatorio usando opciones predefinidas
    final price = SeedData.priceOptions[_random.nextInt(SeedData.priceOptions.length)];

    // Seleccionar síntomas aleatorios (1-3)
    final symptomCount = 1 + _random.nextInt(3);
    final selectedSymptoms = <String>[];
    for (int i = 0; i < symptomCount; i++) {
      final symptom = SeedData.symptoms[_random.nextInt(SeedData.symptoms.length)];
      if (!selectedSymptoms.contains(symptom)) {
        selectedSymptoms.add(symptom);
      }
    }

    // Seleccionar diagnósticos aleatorios (1-2)
    final diagnosisCount = 1 + _random.nextInt(2);
    final selectedDiagnoses = <String>[];
    for (int i = 0; i < diagnosisCount; i++) {
      final diagnosis = SeedData.diagnoses[_random.nextInt(SeedData.diagnoses.length)];
      if (!selectedDiagnoses.contains(diagnosis)) {
        selectedDiagnoses.add(diagnosis);
      }
    }

    // Seleccionar tratamientos aleatorios (1-2)
    final treatmentCount = 1 + _random.nextInt(2);
    final selectedTreatments = <String>[];
    for (int i = 0; i < treatmentCount; i++) {
      final treatment = SeedData.treatments[_random.nextInt(SeedData.treatments.length)];
      if (!selectedTreatments.contains(treatment)) {
        selectedTreatments.add(treatment);
      }
    }

    // Generar medicamentos aleatorios (1-3)
    final medicationCount = 1 + _random.nextInt(3);
    final selectedMedications = <Medication>[];
    for (int i = 0; i < medicationCount; i++) {
      final medData = SeedData.medications[_random.nextInt(SeedData.medications.length)];
      final medication = Medication(
        name: medData['name']!,
        dosage: medData['dosage']!,
        frequency: medData['frequency']!,
        instructions: _generateRandomInstructions(),
      );
      selectedMedications.add(medication);
    }

    return Consultation(
      id: consultationId,
      patientId: patientId,
      date: consultationDate,
      symptoms: selectedSymptoms,
      medications: selectedMedications,
      treatments: selectedTreatments,
      diagnoses: selectedDiagnoses,
      weight: weight,
      observations: _generateRandomObservations(),
      attachments: [], // Sin archivos adjuntos para simplificar
      price: price,
    );
  }

  String? _generateRandomInstructions() {
    return SeedData.instructionOptions[_random.nextInt(SeedData.instructionOptions.length)];
  }

  String? _generateRandomObservations() {
    return SeedData.observationOptions[_random.nextInt(SeedData.observationOptions.length)];
  }

  Future<int> _insertPatientWithSpecificId(Patient patient) async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now().toIso8601String();

    final patientMap = {
      DatabaseConstants.columnId: patient.id,
      DatabaseConstants.columnPatientName: patient.name,
      DatabaseConstants.columnPatientAge: patient.age,
      DatabaseConstants.columnPatientBirthDate: patient.birthDate.toIso8601String(),
      DatabaseConstants.columnPatientPhone: patient.phone,
      DatabaseConstants.columnPatientEmail: patient.email,
      DatabaseConstants.columnPatientGender: patient.gender,
      DatabaseConstants.columnCreatedAt: now,
      DatabaseConstants.columnUpdatedAt: now,
    };

    await db.insert(
      DatabaseConstants.patientsTable,
      patientMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return patient.id!;
  }

  Future<int> _insertConsultationWithSpecificId(Consultation consultation) async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now().toIso8601String();

    return await db.transaction((txn) async {
      final consultationMap = {
        'id': consultation.id,
        DatabaseConstants.columnConsultationPatientId: consultation.patientId,
        DatabaseConstants.columnConsultationDate: consultation.date.toIso8601String(),
        DatabaseConstants.columnConsultationWeight: consultation.weight,
        DatabaseConstants.columnConsultationObservations: consultation.observations,
        DatabaseConstants.columnConsultationPdfPath: consultation.pdfPath,
        DatabaseConstants.columnConsultationPrice: consultation.price,
        DatabaseConstants.columnCreatedAt: now,
        DatabaseConstants.columnUpdatedAt: now,
      };

      await txn.insert(
        DatabaseConstants.consultationsTable,
        consultationMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final consultationId = consultation.id!;

      await _insertSymptoms(txn, consultationId, consultation.symptoms);
      await _insertTreatments(txn, consultationId, consultation.treatments);
      await _insertDiagnoses(txn, consultationId, consultation.diagnoses);

      for (final medication in consultation.medications) {
        await _insertMedication(txn, consultationId, medication);
      }

      for (final attachment in consultation.attachments) {
        await _insertAttachment(txn, consultationId, attachment);
      }

      return consultationId;
    });
  }

  Future<void> _insertSymptoms(Transaction txn, int consultationId, List<String> symptoms) async {
    for (final symptomName in symptoms) {
      final symptomId = await _getOrInsertSymptom(txn, symptomName);
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

  Future<void> _insertTreatments(Transaction txn, int consultationId, List<String> treatments) async {
    for (final treatmentName in treatments) {
      final treatmentId = await _getOrInsertTreatment(txn, treatmentName);
      await txn.insert(
        DatabaseConstants.consultationTreatmentsTable,
        {
          DatabaseConstants.columnJunctionConsultationId: consultationId,
          DatabaseConstants.columnJunctionTreatmentId: treatmentId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _insertDiagnoses(Transaction txn, int consultationId, List<String> diagnoses) async {
    for (final diagnosisName in diagnoses) {
      final diagnosisId = await _getOrInsertDiagnosis(txn, diagnosisName);
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

  Future<int> _getOrInsertTreatment(Transaction txn, String treatmentName) async {
    final result = await txn.query(
      DatabaseConstants.treatmentsTable,
      where: '${DatabaseConstants.columnTreatmentName} = ?',
      whereArgs: [treatmentName],
    );

    if (result.isNotEmpty) {
      return result.first[DatabaseConstants.columnId] as int;
    }

    return await txn.insert(
      DatabaseConstants.treatmentsTable,
      {
        DatabaseConstants.columnTreatmentName: treatmentName,
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
}