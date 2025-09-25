// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Consultation _$ConsultationFromJson(Map<String, dynamic> json) {
  return _Consultation.fromJson(json);
}

/// @nodoc
mixin _$Consultation {
  int? get id => throw _privateConstructorUsedError;
  int get patientId => throw _privateConstructorUsedError;
  DateTime get date =>
      throw _privateConstructorUsedError; // Vital Signs (all optional except legacy weight handling)
  double? get bodyTemperature => throw _privateConstructorUsedError; // °C
  int? get bloodPressureSystolic => throw _privateConstructorUsedError; // mmHg
  int? get bloodPressureDiastolic => throw _privateConstructorUsedError; // mmHg
  double? get oxygenSaturation => throw _privateConstructorUsedError; // %
  double? get weight => throw _privateConstructorUsedError; // kg (now optional)
  double? get height => throw _privateConstructorUsedError; // cm
  // Medical Information
  List<String> get symptoms => throw _privateConstructorUsedError;
  List<String> get diagnoses => throw _privateConstructorUsedError;
  List<Medication> get medications => throw _privateConstructorUsedError;
  List<String> get treatments => throw _privateConstructorUsedError;
  List<Attachment> get attachments => throw _privateConstructorUsedError;
  String? get observations => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get pdfPath => throw _privateConstructorUsedError;

  /// Serializes this Consultation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsultationCopyWith<Consultation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationCopyWith<$Res> {
  factory $ConsultationCopyWith(
    Consultation value,
    $Res Function(Consultation) then,
  ) = _$ConsultationCopyWithImpl<$Res, Consultation>;
  @useResult
  $Res call({
    int? id,
    int patientId,
    DateTime date,
    double? bodyTemperature,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? oxygenSaturation,
    double? weight,
    double? height,
    List<String> symptoms,
    List<String> diagnoses,
    List<Medication> medications,
    List<String> treatments,
    List<Attachment> attachments,
    String? observations,
    double price,
    String? pdfPath,
  });
}

/// @nodoc
class _$ConsultationCopyWithImpl<$Res, $Val extends Consultation>
    implements $ConsultationCopyWith<$Res> {
  _$ConsultationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? patientId = null,
    Object? date = null,
    Object? bodyTemperature = freezed,
    Object? bloodPressureSystolic = freezed,
    Object? bloodPressureDiastolic = freezed,
    Object? oxygenSaturation = freezed,
    Object? weight = freezed,
    Object? height = freezed,
    Object? symptoms = null,
    Object? diagnoses = null,
    Object? medications = null,
    Object? treatments = null,
    Object? attachments = null,
    Object? observations = freezed,
    Object? price = null,
    Object? pdfPath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            patientId: null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            bodyTemperature: freezed == bodyTemperature
                ? _value.bodyTemperature
                : bodyTemperature // ignore: cast_nullable_to_non_nullable
                      as double?,
            bloodPressureSystolic: freezed == bloodPressureSystolic
                ? _value.bloodPressureSystolic
                : bloodPressureSystolic // ignore: cast_nullable_to_non_nullable
                      as int?,
            bloodPressureDiastolic: freezed == bloodPressureDiastolic
                ? _value.bloodPressureDiastolic
                : bloodPressureDiastolic // ignore: cast_nullable_to_non_nullable
                      as int?,
            oxygenSaturation: freezed == oxygenSaturation
                ? _value.oxygenSaturation
                : oxygenSaturation // ignore: cast_nullable_to_non_nullable
                      as double?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double?,
            symptoms: null == symptoms
                ? _value.symptoms
                : symptoms // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            diagnoses: null == diagnoses
                ? _value.diagnoses
                : diagnoses // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            medications: null == medications
                ? _value.medications
                : medications // ignore: cast_nullable_to_non_nullable
                      as List<Medication>,
            treatments: null == treatments
                ? _value.treatments
                : treatments // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<Attachment>,
            observations: freezed == observations
                ? _value.observations
                : observations // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            pdfPath: freezed == pdfPath
                ? _value.pdfPath
                : pdfPath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConsultationImplCopyWith<$Res>
    implements $ConsultationCopyWith<$Res> {
  factory _$$ConsultationImplCopyWith(
    _$ConsultationImpl value,
    $Res Function(_$ConsultationImpl) then,
  ) = __$$ConsultationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int patientId,
    DateTime date,
    double? bodyTemperature,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? oxygenSaturation,
    double? weight,
    double? height,
    List<String> symptoms,
    List<String> diagnoses,
    List<Medication> medications,
    List<String> treatments,
    List<Attachment> attachments,
    String? observations,
    double price,
    String? pdfPath,
  });
}

/// @nodoc
class __$$ConsultationImplCopyWithImpl<$Res>
    extends _$ConsultationCopyWithImpl<$Res, _$ConsultationImpl>
    implements _$$ConsultationImplCopyWith<$Res> {
  __$$ConsultationImplCopyWithImpl(
    _$ConsultationImpl _value,
    $Res Function(_$ConsultationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? patientId = null,
    Object? date = null,
    Object? bodyTemperature = freezed,
    Object? bloodPressureSystolic = freezed,
    Object? bloodPressureDiastolic = freezed,
    Object? oxygenSaturation = freezed,
    Object? weight = freezed,
    Object? height = freezed,
    Object? symptoms = null,
    Object? diagnoses = null,
    Object? medications = null,
    Object? treatments = null,
    Object? attachments = null,
    Object? observations = freezed,
    Object? price = null,
    Object? pdfPath = freezed,
  }) {
    return _then(
      _$ConsultationImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        patientId: null == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        bodyTemperature: freezed == bodyTemperature
            ? _value.bodyTemperature
            : bodyTemperature // ignore: cast_nullable_to_non_nullable
                  as double?,
        bloodPressureSystolic: freezed == bloodPressureSystolic
            ? _value.bloodPressureSystolic
            : bloodPressureSystolic // ignore: cast_nullable_to_non_nullable
                  as int?,
        bloodPressureDiastolic: freezed == bloodPressureDiastolic
            ? _value.bloodPressureDiastolic
            : bloodPressureDiastolic // ignore: cast_nullable_to_non_nullable
                  as int?,
        oxygenSaturation: freezed == oxygenSaturation
            ? _value.oxygenSaturation
            : oxygenSaturation // ignore: cast_nullable_to_non_nullable
                  as double?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double?,
        symptoms: null == symptoms
            ? _value._symptoms
            : symptoms // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        diagnoses: null == diagnoses
            ? _value._diagnoses
            : diagnoses // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        medications: null == medications
            ? _value._medications
            : medications // ignore: cast_nullable_to_non_nullable
                  as List<Medication>,
        treatments: null == treatments
            ? _value._treatments
            : treatments // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<Attachment>,
        observations: freezed == observations
            ? _value.observations
            : observations // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        pdfPath: freezed == pdfPath
            ? _value.pdfPath
            : pdfPath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultationImpl implements _Consultation {
  const _$ConsultationImpl({
    this.id,
    required this.patientId,
    required this.date,
    this.bodyTemperature,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.oxygenSaturation,
    this.weight,
    this.height,
    required final List<String> symptoms,
    required final List<String> diagnoses,
    required final List<Medication> medications,
    required final List<String> treatments,
    required final List<Attachment> attachments,
    this.observations,
    required this.price,
    this.pdfPath,
  }) : _symptoms = symptoms,
       _diagnoses = diagnoses,
       _medications = medications,
       _treatments = treatments,
       _attachments = attachments;

  factory _$ConsultationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationImplFromJson(json);

  @override
  final int? id;
  @override
  final int patientId;
  @override
  final DateTime date;
  // Vital Signs (all optional except legacy weight handling)
  @override
  final double? bodyTemperature;
  // °C
  @override
  final int? bloodPressureSystolic;
  // mmHg
  @override
  final int? bloodPressureDiastolic;
  // mmHg
  @override
  final double? oxygenSaturation;
  // %
  @override
  final double? weight;
  // kg (now optional)
  @override
  final double? height;
  // cm
  // Medical Information
  final List<String> _symptoms;
  // cm
  // Medical Information
  @override
  List<String> get symptoms {
    if (_symptoms is EqualUnmodifiableListView) return _symptoms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symptoms);
  }

  final List<String> _diagnoses;
  @override
  List<String> get diagnoses {
    if (_diagnoses is EqualUnmodifiableListView) return _diagnoses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diagnoses);
  }

  final List<Medication> _medications;
  @override
  List<Medication> get medications {
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medications);
  }

  final List<String> _treatments;
  @override
  List<String> get treatments {
    if (_treatments is EqualUnmodifiableListView) return _treatments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_treatments);
  }

  final List<Attachment> _attachments;
  @override
  List<Attachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final String? observations;
  @override
  final double price;
  @override
  final String? pdfPath;

  @override
  String toString() {
    return 'Consultation(id: $id, patientId: $patientId, date: $date, bodyTemperature: $bodyTemperature, bloodPressureSystolic: $bloodPressureSystolic, bloodPressureDiastolic: $bloodPressureDiastolic, oxygenSaturation: $oxygenSaturation, weight: $weight, height: $height, symptoms: $symptoms, diagnoses: $diagnoses, medications: $medications, treatments: $treatments, attachments: $attachments, observations: $observations, price: $price, pdfPath: $pdfPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.bodyTemperature, bodyTemperature) ||
                other.bodyTemperature == bodyTemperature) &&
            (identical(other.bloodPressureSystolic, bloodPressureSystolic) ||
                other.bloodPressureSystolic == bloodPressureSystolic) &&
            (identical(other.bloodPressureDiastolic, bloodPressureDiastolic) ||
                other.bloodPressureDiastolic == bloodPressureDiastolic) &&
            (identical(other.oxygenSaturation, oxygenSaturation) ||
                other.oxygenSaturation == oxygenSaturation) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.height, height) || other.height == height) &&
            const DeepCollectionEquality().equals(other._symptoms, _symptoms) &&
            const DeepCollectionEquality().equals(
              other._diagnoses,
              _diagnoses,
            ) &&
            const DeepCollectionEquality().equals(
              other._medications,
              _medications,
            ) &&
            const DeepCollectionEquality().equals(
              other._treatments,
              _treatments,
            ) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.observations, observations) ||
                other.observations == observations) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientId,
    date,
    bodyTemperature,
    bloodPressureSystolic,
    bloodPressureDiastolic,
    oxygenSaturation,
    weight,
    height,
    const DeepCollectionEquality().hash(_symptoms),
    const DeepCollectionEquality().hash(_diagnoses),
    const DeepCollectionEquality().hash(_medications),
    const DeepCollectionEquality().hash(_treatments),
    const DeepCollectionEquality().hash(_attachments),
    observations,
    price,
    pdfPath,
  );

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      __$$ConsultationImplCopyWithImpl<_$ConsultationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationImplToJson(this);
  }
}

abstract class _Consultation implements Consultation {
  const factory _Consultation({
    final int? id,
    required final int patientId,
    required final DateTime date,
    final double? bodyTemperature,
    final int? bloodPressureSystolic,
    final int? bloodPressureDiastolic,
    final double? oxygenSaturation,
    final double? weight,
    final double? height,
    required final List<String> symptoms,
    required final List<String> diagnoses,
    required final List<Medication> medications,
    required final List<String> treatments,
    required final List<Attachment> attachments,
    final String? observations,
    required final double price,
    final String? pdfPath,
  }) = _$ConsultationImpl;

  factory _Consultation.fromJson(Map<String, dynamic> json) =
      _$ConsultationImpl.fromJson;

  @override
  int? get id;
  @override
  int get patientId;
  @override
  DateTime get date; // Vital Signs (all optional except legacy weight handling)
  @override
  double? get bodyTemperature; // °C
  @override
  int? get bloodPressureSystolic; // mmHg
  @override
  int? get bloodPressureDiastolic; // mmHg
  @override
  double? get oxygenSaturation; // %
  @override
  double? get weight; // kg (now optional)
  @override
  double? get height; // cm
  // Medical Information
  @override
  List<String> get symptoms;
  @override
  List<String> get diagnoses;
  @override
  List<Medication> get medications;
  @override
  List<String> get treatments;
  @override
  List<Attachment> get attachments;
  @override
  String? get observations;
  @override
  double get price;
  @override
  String? get pdfPath;

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
