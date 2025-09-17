// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DoctorSettingsImpl _$$DoctorSettingsImplFromJson(Map<String, dynamic> json) =>
    _$DoctorSettingsImpl(
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String,
      licenseNumber: json['licenseNumber'] as String,
      clinicName: json['clinicName'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logoPath: json['logoPath'] as String?,
    );

Map<String, dynamic> _$$DoctorSettingsImplToJson(
  _$DoctorSettingsImpl instance,
) => <String, dynamic>{
  'doctorName': instance.doctorName,
  'specialty': instance.specialty,
  'licenseNumber': instance.licenseNumber,
  'clinicName': instance.clinicName,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'logoPath': instance.logoPath,
};
