import 'dart:io';
import 'dart:math' as logger;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/services/services.dart';

class PDFService {
  static const double pageWidth = 21.0 * PdfPageFormat.cm;
  static const double pageHeight = 27.9 * PdfPageFormat.cm;
  static const PdfPageFormat letterFormat = PdfPageFormat(pageWidth, pageHeight);

  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor lightBlue = PdfColor.fromInt(0xFFE3F2FD);
  static const PdfColor darkBlue = PdfColor.fromInt(0xFF1976D2);
  static const PdfColor lightGreen = PdfColor.fromInt(0xFFE8F5E8);
  static const PdfColor darkGreen = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor lightGray = PdfColor.fromInt(0xFFF5F5F5);

  static const String hardcodedDoctorName = 'Dr. José Luis Martínez';
  static const String hardcodedMedicalSchool = 'Universidad Nacional Autónoma de México (UNAM)';

  Future<Uint8List> generatePrescriptionPDF({
    required Patient patient,
    required Consultation consultation,
    required DoctorSettings doctorSettings,
  }) async {
    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    if (doctorSettings.logoPath != null && doctorSettings.logoPath!.isNotEmpty) {
      try {
        final file = File(doctorSettings.logoPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        try {
          final assetBytes = await File('assets/logo.png').readAsBytes();
          logoImage = pw.MemoryImage(assetBytes);
        } catch (assetError) {
          logger.e;

        }
      }
    } else {
      try {
        final assetBytes = await File('assets/logo.png').readAsBytes();
        logoImage = pw.MemoryImage(assetBytes);
      } catch (e) {
        logger.e;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: letterFormat,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildMainHeader(doctorSettings, logoImage),
              
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: _buildDoctorInfo(doctorSettings),
                          ),
                          pw.SizedBox(width: 15),
                          pw.Expanded(
                            child: _buildContactInfo(doctorSettings, consultation),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),

                      _buildPatientInfoSection(patient),
                      pw.SizedBox(height: 12),

                      if (_hasVitalSigns(consultation)) ...[
                        _buildVitalSignsSection(consultation),
                        pw.SizedBox(height: 10),
                      ],


                      if (consultation.diagnoses.isNotEmpty) ...[
                        _buildDiagnosisSection(consultation.diagnoses),
                        pw.SizedBox(height: 10),
                      ],

                      if (consultation.medications.isNotEmpty) ...[
                        _buildMedicationsSection(consultation.medications),
                        pw.SizedBox(height: 10),
                      ],

                      if (consultation.treatments.isNotEmpty) ...[
                        _buildTreatmentsSection(consultation.treatments),
                        pw.SizedBox(height: 10),
                      ],

                      if (consultation.observations != null && consultation.observations!.isNotEmpty) ...[
                        _buildObservationsSection(consultation.observations!),
                        pw.SizedBox(height: 10),
                      ],

                      pw.Spacer(),
                    ],
                  ),
                ),
              ),

              _buildFooterSection(doctorSettings, consultation),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildMainHeader(DoctorSettings doctorSettings, pw.ImageProvider? logoImage) {
    pw.ImageProvider? finalLogo = logoImage;
    
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: primaryBlue,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          finalLogo != null
            ? pw.Container(
                width: 60,
                height: 60,
                child: pw.Image(finalLogo, fit: pw.BoxFit.contain),
              )
            : pw.Container(
                width: 60,
                height: 60,
              ),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                doctorSettings.clinicName ?? 'CENTRO MÉDICO SALUD INTEGRAL',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Cuidando tu salud con excelencia',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.white,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDoctorInfo(DoctorSettings doctorSettings) {
    return pw.Container(
      height: 80, // Altura reducida
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL MÉDICO',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: darkBlue,
            ),
          ),
          pw.SizedBox(height: 6),
          _buildInfoRow('Nombre:', hardcodedDoctorName),
          _buildInfoRow('Especialidad:', doctorSettings.specialty),
          _buildInfoRow('Cédula:', doctorSettings.licenseNumber),
          _buildInfoRow('Universidad:', hardcodedMedicalSchool),
          pw.Spacer(),
        ],
      ),
    );
  }

  pw.Widget _buildContactInfo(DoctorSettings doctorSettings, Consultation consultation) {
    return pw.Container(
      height: 80, // Altura reducida para igualar con doctor info
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CONTACTO',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: darkBlue,
            ),
          ),
          pw.SizedBox(height: 6),
          if (doctorSettings.address != null)
            _buildInfoRow('Dirección:', doctorSettings.address!),
          if (doctorSettings.phone != null)
            _buildInfoRow('Teléfono:', doctorSettings.phone!),
          if (doctorSettings.email != null)
            _buildInfoRow('Email:', doctorSettings.email!),
          _buildInfoRow('Fecha:', _formatDate(consultation.date)),
          pw.Spacer(), // Para empujar el contenido hacia arriba
        ],
      ),
    );
  }

  pw.Widget _buildPatientInfoSection(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightGray,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL PACIENTE',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: darkBlue,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Nombre:', patient.name),
              ),
              pw.Expanded(
                child: _buildInfoRow('Edad:', '${patient.age} años'),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Sexo:', patient.gender),
              ),
              pw.Expanded(
                child: _buildInfoRow('Teléfono:', patient.phone),
              ),
            ],
          ),
          if (patient.email != null) 
            _buildInfoRow('Email:', patient.email!),
        ],
      ),
    );
  }

  pw.Widget _buildVitalSignsSection(Consultation consultation) {
    final vitalSignsWidgets = <pw.Widget>[];

    if (consultation.bloodPressureSystolic != null && consultation.bloodPressureDiastolic != null) {
      vitalSignsWidgets.add(_buildVitalSignBox(
        'Presión Arterial',
        '${consultation.bloodPressureSystolic}/${consultation.bloodPressureDiastolic} mmHg',
      ));
    }

    if (consultation.bodyTemperature != null) {
      vitalSignsWidgets.add(_buildVitalSignBox(
        'Temperatura',
        '${consultation.bodyTemperature!.toStringAsFixed(1)}°C',
      ));
    }

    if (consultation.oxygenSaturation != null) {
      vitalSignsWidgets.add(_buildVitalSignBox(
        'Saturación O2',
        '${consultation.oxygenSaturation!.toStringAsFixed(0)}%',
      ));
    }

    if (consultation.weight != null) {
      vitalSignsWidgets.add(_buildVitalSignBox(
        'Peso',
        '${consultation.weight!.toStringAsFixed(1)} kg',
      ));
    }

    if (consultation.height != null) {
      vitalSignsWidgets.add(_buildVitalSignBox(
        'Altura',
        '${consultation.height!.toStringAsFixed(0)} cm',
      ));
    }

    if (vitalSignsWidgets.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SIGNOS VITALES',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: darkBlue,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: vitalSignsWidgets.take(4).map((widget) => 
            pw.Expanded(child: pw.Padding(
              padding: const pw.EdgeInsets.only(right: 8),
              child: widget,
            ))
          ).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildVitalSignBox(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: lightBlue,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: primaryBlue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: darkBlue,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDiagnosisSection(List<String> diagnoses) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightBlue,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: primaryBlue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DIAGNÓSTICO',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: darkBlue,
            ),
          ),
          pw.SizedBox(height: 6),
          ...diagnoses.asMap().entries.map((entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${entry.key + 1}. ',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    entry.value,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  pw.Widget _buildMedicationsSection(List<Medication> medications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TRATAMIENTO Y MEDICAMENTOS RECETADOS',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: darkBlue,
          ),
        ),
        pw.SizedBox(height: 6),
        ...medications.asMap().entries.map((entry) {
          int index = entry.key;
          Medication medication = entry.value;
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${index + 1}. ${medication.name}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                pw.SizedBox(height: 4),
                _buildMedicationDetail('Dosis:', medication.dosage),
                _buildMedicationDetail('Frecuencia:', medication.frequency),
                if (medication.instructions != null)
                  _buildMedicationDetail('Indicación:', medication.instructions!),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildTreatmentsSection(List<String> treatments) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TRATAMIENTOS ADICIONALES',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: darkBlue,
          ),
        ),
        pw.SizedBox(height: 4),
        ...treatments.asMap().entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${entry.key + 1}. ',
                style: pw.TextStyle(
                  fontSize: 9, 
                  color: darkBlue,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  entry.value,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  pw.Widget _buildMedicationDetail(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildObservationsSection(String observations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'OBSERVACIONES MÉDICAS',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: darkBlue,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: lightGreen,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: darkGreen, width: 1),
          ),
          child: pw.Text(
            observations,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFooterSection(DoctorSettings doctorSettings, Consultation consultation) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: primaryBlue,
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.SizedBox(height: 20), // Espacio para la firma
            pw.Container(
              width: 150,
              height: 1,
              color: PdfColors.white,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              hardcodedDoctorName,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasVitalSigns(Consultation consultation) {
    return consultation.bodyTemperature != null ||
           consultation.bloodPressureSystolic != null ||
           consultation.bloodPressureDiastolic != null ||
           consultation.oxygenSaturation != null ||
           consultation.weight != null ||
           consultation.height != null;
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    final days = [
      'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
    ];

    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Future<String> savePDFToStorage(Uint8List pdfBytes, String fileName, Patient patient, DateTime consultationDate) async {
    final filePath = await FileOrganizationService.getConsultationFilePath(patient, consultationDate, fileName);
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  Future<void> previewPDF(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
      format: letterFormat,
    );
  }

  Future<void> printPDF(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
      format: letterFormat,
    );
  }

  Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }
}