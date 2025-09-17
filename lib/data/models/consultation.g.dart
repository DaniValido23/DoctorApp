// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsultationImpl _$$ConsultationImplFromJson(Map<String, dynamic> json) =>
    _$ConsultationImpl(
      id: (json['id'] as num?)?.toInt(),
      patientId: (json['patientId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList(),
      treatments: (json['treatments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      weight: (json['weight'] as num).toDouble(),
      observations: json['observations'] as String?,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$$ConsultationImplToJson(_$ConsultationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'date': instance.date.toIso8601String(),
      'symptoms': instance.symptoms,
      'medications': instance.medications,
      'treatments': instance.treatments,
      'diagnoses': instance.diagnoses,
      'weight': instance.weight,
      'observations': instance.observations,
      'attachments': instance.attachments,
      'price': instance.price,
    };
