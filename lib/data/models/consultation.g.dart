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
      bodyTemperature: (json['bodyTemperature'] as num?)?.toDouble(),
      bloodPressureSystolic: (json['bloodPressureSystolic'] as num?)?.toInt(),
      bloodPressureDiastolic: (json['bloodPressureDiastolic'] as num?)?.toInt(),
      oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList(),
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      observations: json['observations'] as String?,
      price: (json['price'] as num).toDouble(),
      pdfPath: json['pdfPath'] as String?,
    );

Map<String, dynamic> _$$ConsultationImplToJson(_$ConsultationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'date': instance.date.toIso8601String(),
      'bodyTemperature': instance.bodyTemperature,
      'bloodPressureSystolic': instance.bloodPressureSystolic,
      'bloodPressureDiastolic': instance.bloodPressureDiastolic,
      'oxygenSaturation': instance.oxygenSaturation,
      'weight': instance.weight,
      'height': instance.height,
      'symptoms': instance.symptoms,
      'diagnoses': instance.diagnoses,
      'medications': instance.medications,
      'attachments': instance.attachments,
      'observations': instance.observations,
      'price': instance.price,
      'pdfPath': instance.pdfPath,
    };
