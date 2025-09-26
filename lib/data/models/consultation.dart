import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:doctor_app/data/models/medication.dart';
import 'package:doctor_app/data/models/attachment.dart';

part 'consultation.freezed.dart';
part 'consultation.g.dart';

@freezed
class Consultation with _$Consultation {
  const factory Consultation({
    int? id,
    required int patientId,
    required DateTime date,
    // Vital Signs (all optional except legacy weight handling)
    double? bodyTemperature,      // °C
    int? bloodPressureSystolic,   // mmHg
    int? bloodPressureDiastolic,  // mmHg
    double? oxygenSaturation,     // %
    double? weight,               // kg (now optional)
    double? height,               // cm
    // Medical Information
    required List<String> symptoms,
    required List<String> diagnoses,
    required List<Medication> medications,
    required List<Attachment> attachments,
    String? observations,
    required double price,
    String? pdfPath,
  }) = _Consultation;

  factory Consultation.fromJson(Map<String, dynamic> json) => _$ConsultationFromJson(json);
}