class DatabaseConstants {
  static const String databaseName = 'doctor_app.db';
  static const int databaseVersion = 3;

  // Table names
  static const String patientsTable = 'patients';
  static const String consultationsTable = 'consultations';
  static const String medicationsTable = 'medications';
  static const String symptomsTable = 'symptoms';
  static const String treatmentsTable = 'treatments';
  static const String diagnosesTable = 'diagnoses';
  static const String attachmentsTable = 'attachments';
  static const String consultationSymptomsTable = 'consultation_symptoms';
  static const String consultationTreatmentsTable = 'consultation_treatments';
  static const String consultationDiagnosesTable = 'consultation_diagnoses';

  // Common columns
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Patients table columns
  static const String columnPatientName = 'name';
  static const String columnPatientAge = 'age';
  static const String columnPatientBirthDate = 'birth_date';
  static const String columnPatientPhone = 'phone';
  static const String columnPatientEmail = 'email';
  static const String columnPatientGender = 'gender';

  // Consultations table columns
  static const String columnConsultationPatientId = 'patient_id';
  static const String columnConsultationDate = 'date';
  // Vital Signs (all optional)
  static const String columnConsultationBodyTemperature = 'body_temperature';
  static const String columnConsultationBloodPressureSystolic = 'blood_pressure_systolic';
  static const String columnConsultationBloodPressureDiastolic = 'blood_pressure_diastolic';
  static const String columnConsultationOxygenSaturation = 'oxygen_saturation';
  static const String columnConsultationWeight = 'weight';
  static const String columnConsultationHeight = 'height';
  // Other fields
  static const String columnConsultationObservations = 'observations';
  static const String columnConsultationPrice = 'price';
  static const String columnConsultationPdfPath = 'pdf_path';

  // Medications table columns
  static const String columnMedicationConsultationId = 'consultation_id';
  static const String columnMedicationName = 'name';
  static const String columnMedicationDosage = 'dosage';
  static const String columnMedicationFrequency = 'frequency';
  static const String columnMedicationInstructions = 'instructions';

  // Symptoms table columns
  static const String columnSymptomName = 'name';

  // Treatments table columns
  static const String columnTreatmentName = 'name';

  // Diagnoses table columns
  static const String columnDiagnosisName = 'name';

  // Attachments table columns
  static const String columnAttachmentConsultationId = 'consultation_id';
  static const String columnAttachmentFileName = 'file_name';
  static const String columnAttachmentFilePath = 'file_path';
  static const String columnAttachmentFileType = 'file_type';
  static const String columnAttachmentUploadedAt = 'uploaded_at';

  // Junction table columns
  static const String columnJunctionConsultationId = 'consultation_id';
  static const String columnJunctionSymptomId = 'symptom_id';
  static const String columnJunctionTreatmentId = 'treatment_id';
  static const String columnJunctionDiagnosisId = 'diagnosis_id';
}