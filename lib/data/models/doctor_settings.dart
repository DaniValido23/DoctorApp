import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_settings.freezed.dart';
part 'doctor_settings.g.dart';

@freezed
class DoctorSettings with _$DoctorSettings {
  const factory DoctorSettings({
    required String doctorName,
    required String specialty,
    required String licenseNumber,
    String? clinicName,
    String? address,
    String? phone,
    String? email,
    String? logoPath,
  }) = _DoctorSettings;

  factory DoctorSettings.fromJson(Map<String, dynamic> json) => _$DoctorSettingsFromJson(json);
}