// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientImpl _$$PatientImplFromJson(Map<String, dynamic> json) =>
    _$PatientImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      birthDate: DateTime.parse(json['birthDate'] as String),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      gender: json['gender'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PatientImplToJson(_$PatientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'birthDate': instance.birthDate.toIso8601String(),
      'phone': instance.phone,
      'email': instance.email,
      'gender': instance.gender,
      'createdAt': instance.createdAt.toIso8601String(),
    };
