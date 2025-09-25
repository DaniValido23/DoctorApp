import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:doctor_app/presentation/pages/consultation/widgets/widgets.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'package:doctor_app/services/services.dart';
import 'package:doctor_app/core/utils/utils.dart';

class ConsultationPage extends ConsumerStatefulWidget {
  final int patientId;

  const ConsultationPage({super.key, required this.patientId});

  @override
  ConsumerState<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends ConsumerState<ConsultationPage> {
  final _formKey = GlobalKey<FormState>();

  // Vital Signs Controllers
  final _temperatureController = TextEditingController();
  final _systolicPressureController = TextEditingController();
  final _diastolicPressureController = TextEditingController();
  final _oxygenSaturationController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Other Controllers
  final _priceController = TextEditingController();
  final _observationsController = TextEditingController();

  // Data
  List<String> _symptoms = [];
  List<Medication> _medications = [];
  List<String> _treatments = [];
  List<String> _diagnoses = [];
  List<Attachment> _attachments = [];

  Patient? _patient;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await ref
        .read(patientProvider.notifier)
        .getPatientById(widget.patientId);
    if (mounted) {
      setState(() {
        _patient = patient;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva consulta de ${_patient!.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _onCancel,
              tooltip: 'Cancelar consulta',
            ),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildScrollableForm(),
        desktop: _buildScrollableForm(),
      ),
    );
  }

  Widget _buildScrollableForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 1000;
            final isMediumScreen = constraints.maxWidth > 600;

            if (isWideScreen) {
              return _buildWideScreenLayout();
            } else if (isMediumScreen) {
              return _buildMediumScreenLayout();
            } else {
              return _buildNarrowScreenLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 1. Signos Vitales (full width)
          VitalSignsSection(
            temperatureController: _temperatureController,
            systolicPressureController: _systolicPressureController,
            diastolicPressureController: _diastolicPressureController,
            oxygenSaturationController: _oxygenSaturationController,
            weightController: _weightController,
            heightController: _heightController,
          ),

          // Row 1: Síntomas del paciente, Diagnósticos médicos
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildSection(
                    title: 'Síntomas del paciente',
                    icon: Icons.sick,
                    child: SymptomForm(
                      initialSymptoms: _symptoms,
                      onSymptomsChanged: (symptoms) =>
                          setState(() => _symptoms = symptoms),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    title: 'Diagnósticos médicos',
                    icon: Icons.medical_services,
                    child: DiagnosisForm(
                      initialDiagnoses: _diagnoses,
                      onDiagnosesChanged: (diagnoses) =>
                          setState(() => _diagnoses = diagnoses),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 2: Medicamentos, Plan de tratamiento
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildSection(
                    title: 'Medicamentos',
                    icon: Icons.medication,
                    child: MedicationForm(
                      initialMedications: _medications,
                      onMedicationsChanged: (medications) =>
                          setState(() => _medications = medications),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    title: 'Plan de tratamiento',
                    icon: Icons.healing,
                    child: TreatmentForm(
                      initialTreatments: _treatments,
                      onTreatmentsChanged: (treatments) =>
                          setState(() => _treatments = treatments),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 3: Observaciones (1/2), Precio de consulta (1/4), Estudios médicos (1/4)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2, // 1/2 del espacio
                  child: _buildSection(
                    title: 'Observaciones',
                    icon: Icons.notes,
                    child: _buildObservationsField(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1, // 1/4 del espacio
                  child: _buildSection(
                    title: 'Precio de consulta',
                    icon: Icons.attach_money,
                    child: _buildPriceField(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1, // 1/4 del espacio
                  child: _buildSection(
                    title: 'Estudios médicos',
                    icon: Icons.attach_file,
                    child: AttachmentWidget(
                      initialAttachments: _attachments,
                      onAttachmentsChanged: (attachments) =>
                          setState(() => _attachments = attachments),
                      patient: _patient,
                      consultationDate: DateTime.now(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMediumScreenLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 1. Signos Vitales (full width)
          VitalSignsSection(
            temperatureController: _temperatureController,
            systolicPressureController: _systolicPressureController,
            diastolicPressureController: _diastolicPressureController,
            oxygenSaturationController: _oxygenSaturationController,
            weightController: _weightController,
            heightController: _heightController,
          ),

          // Row 1: Síntomas del paciente, Diagnósticos médicos
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildSection(
                    title: 'Síntomas del paciente',
                    icon: Icons.sick,
                    child: SymptomForm(
                      initialSymptoms: _symptoms,
                      onSymptomsChanged: (symptoms) =>
                          setState(() => _symptoms = symptoms),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    title: 'Diagnósticos médicos',
                    icon: Icons.medical_services,
                    child: DiagnosisForm(
                      initialDiagnoses: _diagnoses,
                      onDiagnosesChanged: (diagnoses) =>
                          setState(() => _diagnoses = diagnoses),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 2: Medicamentos, Plan de tratamiento
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildSection(
                    title: 'Medicamentos',
                    icon: Icons.medication,
                    child: MedicationForm(
                      initialMedications: _medications,
                      onMedicationsChanged: (medications) =>
                          setState(() => _medications = medications),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    title: 'Plan de tratamiento',
                    icon: Icons.healing,
                    child: TreatmentForm(
                      initialTreatments: _treatments,
                      onTreatmentsChanged: (treatments) =>
                          setState(() => _treatments = treatments),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 3: Observaciones (full width)
          _buildSection(
            title: 'Observaciones',
            icon: Icons.notes,
            child: _buildObservationsField(),
          ),

          const SizedBox(height: 16),

          // Row 4: Precio de consulta, Estudios médicos
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildSection(
                    title: 'precio de consulta',
                    icon: Icons.attach_money,
                    child: _buildPriceField(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    title: 'Estudios médicos',
                    icon: Icons.attach_file,
                    child: AttachmentWidget(
                      initialAttachments: _attachments,
                      onAttachmentsChanged: (attachments) =>
                          setState(() => _attachments = attachments),
                      patient: _patient,
                      consultationDate: DateTime.now(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildNarrowScreenLayout() {
    return Column(
      children: [
        // 1. Signos Vitales
        VitalSignsSection(
          temperatureController: _temperatureController,
          systolicPressureController: _systolicPressureController,
          diastolicPressureController: _diastolicPressureController,
          oxygenSaturationController: _oxygenSaturationController,
          weightController: _weightController,
          heightController: _heightController,
        ),

        // 2. Síntomas del Paciente
        _buildSection(
          title: 'Síntomas del paciente',
          icon: Icons.sick,
          child: SymptomForm(
            initialSymptoms: _symptoms,
            onSymptomsChanged: (symptoms) =>
                setState(() => _symptoms = symptoms),
          ),
        ),

        // 3. Diagnósticos Médicos
        _buildSection(
          title: 'Diagnósticos Médicos',
          icon: Icons.medical_services,
          child: DiagnosisForm(
            initialDiagnoses: _diagnoses,
            onDiagnosesChanged: (diagnoses) =>
                setState(() => _diagnoses = diagnoses),
          ),
        ),

        // 4. Medicamentos
        _buildSection(
          title: 'Medicamentos',
          icon: Icons.medication,
          child: MedicationForm(
            initialMedications: _medications,
            onMedicationsChanged: (medications) =>
                setState(() => _medications = medications),
          ),
        ),

        // 5. Plan de Tratamiento
        _buildSection(
          title: 'Plan de Tratamiento',
          icon: Icons.healing,
          child: TreatmentForm(
            initialTreatments: _treatments,
            onTreatmentsChanged: (treatments) =>
                setState(() => _treatments = treatments),
          ),
        ),

        // 6. Archivos Adjuntos
        _buildSection(
          title: 'Estudios médicos',
          icon: Icons.attach_file,
          child: AttachmentWidget(
            initialAttachments: _attachments,
            onAttachmentsChanged: (attachments) =>
                setState(() => _attachments = attachments),
            patient: _patient,
            consultationDate: DateTime.now(),
          ),
        ),

        // 7. Observaciones
        _buildSection(
          title: 'Observaciones',
          icon: Icons.notes,
          child: _buildObservationsField(),
        ),

        // 8. Precio
        _buildSection(
          title: 'Precio de consulta',
          icon: Icons.attach_money,
          child: _buildPriceField(),
        ),

        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SizedBox(
        height:
            title == 'Observaciones' ||
                title == 'Precio de consulta' ||
                title == 'Estudios médicos'
            ? 250
            : 600,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: theme.primaryColor, size: 25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section Content
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObservationsField() {
    return TextFormField(
      controller: _observationsController,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: 'Observaciones adicionales',
        hintText:
            'Escriba cualquier observación adicional sobre la consulta...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Precio (\$) *',
        hintText: '500.00',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value?.isEmpty == true) return 'El precio es requerido';
        final price = double.tryParse(value!);
        if (price == null) return 'Precio inválido';
        if (price < 0) return 'El precio no puede ser negativo';
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _onCancel,
            icon: const Icon(Icons.clear),
            label: const Text('Cancelar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            ),
          ),
          const SizedBox(width: 30),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveConsultation,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isLoading ? 'Guardando...' : 'Guardar Consulta'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateConsultationData() {
    final errors = <String>[];

    // Validar campos del formulario
    if (!_formKey.currentState!.validate()) {
      errors.add('Completa todos los campos requeridos');
    }

    // Validar que haya al menos un síntoma
    if (_symptoms.isEmpty) {
      errors.add('Agrega al menos un síntoma');
    }

    // Validar que haya al menos un diagnóstico
    if (_diagnoses.isEmpty) {
      errors.add('Agrega al menos un diagnóstico');
    }

    // Mostrar errores si los hay
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Errores de validación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...errors.map((error) => Text('• $error')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveConsultation() async {
    if (!_validateConsultationData()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create consultation first
      final consultation = Consultation(
        patientId: widget.patientId,
        date: DateTime.now(),
        // Vital Signs
        bodyTemperature: _temperatureController.text.trim().isEmpty
            ? null
            : double.tryParse(_temperatureController.text),
        bloodPressureSystolic: _systolicPressureController.text.trim().isEmpty
            ? null
            : int.tryParse(_systolicPressureController.text),
        bloodPressureDiastolic: _diastolicPressureController.text.trim().isEmpty
            ? null
            : int.tryParse(_diastolicPressureController.text),
        oxygenSaturation: _oxygenSaturationController.text.trim().isEmpty
            ? null
            : double.tryParse(_oxygenSaturationController.text),
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text),
        height: _heightController.text.trim().isEmpty
            ? null
            : double.tryParse(_heightController.text),
        // Medical Information
        symptoms: _symptoms,
        diagnoses: _diagnoses,
        medications: _medications,
        treatments: _treatments,
        attachments: _attachments,
        observations: _observationsController.text.trim().isEmpty
            ? null
            : _observationsController.text.trim(),
        price: double.parse(_priceController.text),
      );

      // Save consultation to database
      final savedConsultation = await ref
          .read(consultationProvider.notifier)
          .addConsultation(consultation);

      // Generate PDF
      await _generateAndSavePDF(savedConsultation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Consulta guardada exitosamente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form and navigate back after successful save
        _onSaveSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error al guardar la consulta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('$e'),
                const SizedBox(height: 8),
                const Text(
                  'Los datos del formulario se mantienen para reintentarlo',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateAndSavePDF(Consultation consultation) async {
    try {
      final settingsAsync = ref.read(settingsProvider);

      if (settingsAsync.hasError) {
        throw 'Error al cargar configuraciones del doctor: ${settingsAsync.error}';
      }

      DoctorSettings doctorSettings;
      if (!settingsAsync.hasValue || settingsAsync.value == null) {
        // Create default settings temporarily
        doctorSettings = const DoctorSettings(
          doctorName: 'Dr. [Nombre del Doctor]',
          specialty: 'Medicina General',
          licenseNumber: '123456',
          clinicName: 'Clínica Médica',
          address: 'Dirección de la clínica',
          phone: '(000) 000-0000',
          email: 'doctor@clinica.com',
        );

        // Save default settings for future use
        await ref
            .read(settingsProvider.notifier)
            .updateSettings(doctorSettings);
      } else {
        doctorSettings = settingsAsync.value!;
      }

      final pdfService = PDFService();

      // Generate PDF
      final pdfBytes = await pdfService.generatePrescriptionPDF(
        patient: _patient!,
        consultation: consultation,
        doctorSettings: doctorSettings,
      );

      // Save PDF to consultation folder
      final fileName = FileOrganizationService.generateConsultationPDFName(
        _patient!,
        consultation.date,
      );
      final pdfPath = await pdfService.savePDFToStorage(
        pdfBytes,
        fileName,
        _patient!,
        consultation.date,
      );

      // Update consultation with PDF path
      final updatedConsultation = consultation.copyWith(pdfPath: pdfPath);
      await ref
          .read(consultationProvider.notifier)
          .updateConsultation(updatedConsultation);

      // Auto-open PDF with system default app
      await _openFile(pdfPath, 'PDF');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _openFile(String filePath, [String? fileType]) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'El archivo${fileType != null ? ' $fileType' : ''} no existe',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Usar comandos específicos del sistema operativo
      if (Platform.isWindows) {
        await Process.run('start', ['', filePath], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [filePath]);
      } else {
        try {
          final uri = Uri.file(filePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            throw 'No se puede abrir el archivo en esta plataforma';
          }
        } catch (e) {
          // Último fallback para PDFs
          if (fileType == 'PDF' || filePath.toLowerCase().endsWith('.pdf')) {
            final pdfBytes = await file.readAsBytes();
            await Printing.layoutPdf(
              onLayout: (format) async => pdfBytes,
              name: 'Documento_${DateTime.now().millisecondsSinceEpoch}',
            );
          } else {
            rethrow;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al abrir${fileType != null ? ' $fileType' : ' archivo'}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Maneja la cancelación de la consulta - limpia el formulario
  void _onCancel() {
    _clearForm();
    context.go('/patients/${widget.patientId}');
  }

  /// Maneja el guardado exitoso - limpia el formulario
  void _onSaveSuccess() {
    _clearForm();
    context.go('/patients/${widget.patientId}');
  }

  void _clearForm() {
    // Clear vital signs controllers
    _temperatureController.clear();
    _systolicPressureController.clear();
    _diastolicPressureController.clear();
    _oxygenSaturationController.clear();
    _weightController.clear();
    _heightController.clear();

    // Clear other controllers
    _priceController.clear();
    _observationsController.clear();

    setState(() {
      _symptoms.clear();
      _medications.clear();
      _treatments.clear();
      _diagnoses.clear();
      _attachments.clear();
    });
  }

  @override
  void dispose() {
    // Dispose vital signs controllers
    _temperatureController.dispose();
    _systolicPressureController.dispose();
    _diastolicPressureController.dispose();
    _oxygenSaturationController.dispose();
    _weightController.dispose();
    _heightController.dispose();

    // Dispose other controllers
    _priceController.dispose();
    _observationsController.dispose();

    super.dispose();
  }
}
