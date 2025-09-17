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
    required List<String> symptoms,
    required List<Medication> medications,
    required List<String> treatments,
    required List<String> diagnoses,
    required double weight,
    String? observations,
    required List<Attachment> attachments,
    required double price,
  }) = _Consultation;

  factory Consultation.fromJson(Map<String, dynamic> json) => _$ConsultationFromJson(json);
}