import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/services/services.dart';

class PDFService {
  static const double pageWidth = 21.0 * PdfPageFormat.cm; // Letter size width
  static const double pageHeight = 27.9 * PdfPageFormat.cm; // Letter size height
  static const PdfPageFormat letterFormat = PdfPageFormat(pageWidth, pageHeight);

  // Hardcoded doctor information
  static const String hardcodedDoctorName = 'Dr. José Luis Martínez';
  static const String hardcodedMedicalSchool = 'Universidad Nacional Autónoma de México (UNAM)';

  /// Generate prescription PDF for a patient consultation
  Future<Uint8List> generatePrescriptionPDF({
    required Patient patient,
    required Consultation consultation,
    required DoctorSettings doctorSettings,
  }) async {
    final pdf = pw.Document();

    // Load doctor logo if available
    pw.ImageProvider? logoImage;
    if (doctorSettings.logoPath != null && doctorSettings.logoPath!.isNotEmpty) {
      try {
        final file = File(doctorSettings.logoPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          logoImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        // If logo loading fails, continue without logo
        // Error loading logo: $e
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: letterFormat,
        margin: const pw.EdgeInsets.all(2.0 * PdfPageFormat.cm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with doctor info and logo
              _buildHeader(doctorSettings, logoImage),
              pw.SizedBox(height: 20),

              // Title
              pw.Center(
                child: pw.Text(
                  'RECETA MÉDICA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Patient information
              _buildPatientInfo(patient),
              pw.SizedBox(height: 20),

              // Consultation date and details
              _buildConsultationInfo(consultation),
              pw.SizedBox(height: 20),

              // Symptoms
              if (consultation.symptoms.isNotEmpty) ...[
                _buildSection('SÍNTOMAS', consultation.symptoms),
                pw.SizedBox(height: 15),
              ],

              // Diagnoses
              if (consultation.diagnoses.isNotEmpty) ...[
                _buildSection('DIAGNÓSTICOS', consultation.diagnoses),
                pw.SizedBox(height: 15),
              ],

              // Medications (main section)
              if (consultation.medications.isNotEmpty) ...[
                _buildMedicationsSection(consultation.medications),
                pw.SizedBox(height: 15),
              ],

              // Treatments
              if (consultation.treatments.isNotEmpty) ...[
                _buildSection('TRATAMIENTOS', consultation.treatments),
                pw.SizedBox(height: 15),
              ],

              // Observations
              if (consultation.observations != null && consultation.observations!.isNotEmpty) ...[
                _buildObservations(consultation.observations!),
                pw.SizedBox(height: 15),
              ],

              // Vital signs information
              _buildVitalSignsInfo(consultation),

              pw.Spacer(),

              // Footer with doctor signature
              _buildFooter(doctorSettings),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build header with doctor information and logo
  pw.Widget _buildHeader(DoctorSettings doctorSettings, pw.ImageProvider? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Doctor information
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                hardcodedDoctorName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                doctorSettings.specialty,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                hardcodedMedicalSchool,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Cédula Profesional: ${doctorSettings.licenseNumber}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              if (doctorSettings.titles != null && doctorSettings.titles!.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  doctorSettings.titles!,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
              if (doctorSettings.clinicName != null) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  doctorSettings.clinicName!,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
              if (doctorSettings.address != null) ...[
                pw.Text(
                  doctorSettings.address!,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
              if (doctorSettings.phone != null) ...[
                pw.Text(
                  'Tel: ${doctorSettings.phone}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
              if (doctorSettings.email != null) ...[
                pw.Text(
                  'Email: ${doctorSettings.email}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ],
          ),
        ),
        // Logo
        if (logoImage != null)
          pw.Container(
            width: 80,
            height: 80,
            child: pw.Image(logoImage),
          ),
      ],
    );
  }

  /// Build patient information section
  pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL PACIENTE',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Nombre: ${patient.name}', style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.Expanded(
                child: pw.Text('Edad: ${patient.age} años', style: const pw.TextStyle(fontSize: 12)),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Sexo: ${patient.gender}', style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.Expanded(
                child: pw.Text('Teléfono: ${patient.phone}', style: const pw.TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (patient.email != null) ...[
            pw.SizedBox(height: 4),
            pw.Text('Email: ${patient.email}', style: const pw.TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  /// Build consultation information
  pw.Widget _buildConsultationInfo(Consultation consultation) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Fecha de consulta: ${_formatDate(consultation.date)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a general section (symptoms, diagnoses, treatments)
  pw.Widget _buildSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        ...items.map((item) => pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
          child: pw.Text('- $item', style: const pw.TextStyle(fontSize: 12)),
        )),
      ],
    );
  }

  /// Build medications section with detailed information
  pw.Widget _buildMedicationsSection(List<Medication> medications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MEDICAMENTOS RECETADOS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Medicamento',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Dosis',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Frecuencia',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Instrucciones',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              // Medications
              ...medications.map((medication) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(medication.name, style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(medication.dosage, style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(medication.frequency, style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      medication.instructions ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  /// Build observations section
  pw.Widget _buildObservations(String observations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Icon(
              pw.IconData(0xe8b9), // notes icon
              size: 16,
              color: PdfColors.grey700,
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'OBSERVACIONES MÉDICAS',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            border: pw.Border.all(color: PdfColors.grey400, width: 1),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            observations,
            style: pw.TextStyle(
              fontSize: 12,
              lineSpacing: 1.4,
              color: PdfColors.grey800,
            ),
          ),
        ),
      ],
    );
  }

  /// Build vital signs information
  pw.Widget _buildVitalSignsInfo(Consultation consultation) {
    final vitalSigns = <String>[];

    // Add vital signs if they exist
    if (consultation.bodyTemperature != null) {
      vitalSigns.add('Temperatura: ${consultation.bodyTemperature!.toStringAsFixed(1)}°C');
    }

    if (consultation.bloodPressureSystolic != null && consultation.bloodPressureDiastolic != null) {
      vitalSigns.add('Presión Arterial: ${consultation.bloodPressureSystolic}/${consultation.bloodPressureDiastolic} mmHg');
    }

    if (consultation.oxygenSaturation != null) {
      vitalSigns.add('Saturación de O₂: ${consultation.oxygenSaturation!.toStringAsFixed(1)}%');
    }

    if (consultation.weight != null) {
      vitalSigns.add('Peso: ${consultation.weight!.toStringAsFixed(1)} kg');
    }

    if (consultation.height != null) {
      vitalSigns.add('Altura: ${consultation.height!.toStringAsFixed(0)} cm');
    }

    // If no vital signs are recorded, don't display the section
    if (vitalSigns.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Icon(
                pw.IconData(0xe8b6), // monitor_heart icon
                size: 16,
                color: PdfColors.blue700,
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'SIGNOS VITALES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 20,
            runSpacing: 6,
            children: vitalSigns.map((sign) => pw.Text(
              sign,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey800,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// Build footer with doctor signature
  pw.Widget _buildFooter(DoctorSettings doctorSettings) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          hardcodedDoctorName,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          doctorSettings.specialty,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          'Cédula Profesional: ${doctorSettings.licenseNumber}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Save PDF to consultation folder in organized structure
  Future<String> savePDFToStorage(Uint8List pdfBytes, String fileName, Patient patient, DateTime consultationDate) async {
    final filePath = await FileOrganizationService.getConsultationFilePath(patient, consultationDate, fileName);
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// Preview PDF using the printing package
  Future<void> previewPDF(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
      format: letterFormat,
    );
  }

  /// Print PDF directly
  Future<void> printPDF(Uint8List pdfBytes, String title) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
      format: letterFormat,
    );
  }

  /// Share PDF
  Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }
}