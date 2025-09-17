import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@freezed
class Patient with _$Patient {
  const factory Patient({
    int? id,
    required String name,
    required int age,
    required DateTime birthDate,
    required String phone,
    String? email,
    required String gender,
    required DateTime createdAt,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
}