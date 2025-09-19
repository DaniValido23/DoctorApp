import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/data/models/consultation.dart';
import 'package:doctor_app/data/models/medication.dart';
import 'package:doctor_app/data/models/attachment.dart';
import 'package:doctor_app/presentation/providers/patient_provider.dart';
import 'package:doctor_app/presentation/providers/consultation_provider.dart';
import 'package:doctor_app/presentation/pages/consultation/widgets/symptom_form.dart';
import 'package:doctor_app/presentation/pages/consultation/widgets/medication_form.dart';
import 'package:doctor_app/presentation/pages/consultation/widgets/treatment_form.dart';
import 'package:doctor_app/presentation/pages/consultation/widgets/diagnosis_form.dart';
import 'package:doctor_app/presentation/pages/consultation/widgets/attachment_widget.dart';
import 'package:doctor_app/services/pdf_service.dart';
import 'package:doctor_app/presentation/providers/settings_provider.dart';
import 'package:doctor_app/data/models/doctor_settings.dart';
import 'package:doctor_app/core/utils/responsive_utils.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';

class ConsultationPage extends ConsumerStatefulWidget {
  final int patientId;

  const ConsultationPage({super.key, required this.patientId});

  @override
  ConsumerState<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends ConsumerState<ConsultationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers
  final _weightController = TextEditingController();
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
    _tabController = TabController(length: 6, vsync: this);
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await ref.read(patientProvider.notifier).getPatientById(widget.patientId);
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
        title: Text('Consulta - ${_patient!.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/patients/${widget.patientId}'),
            tooltip: 'Ver historial de consultas',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(icon: Icon(Icons.sick), text: 'Síntomas'),
            Tab(icon: Icon(Icons.medication), text: 'Medicamentos'),
            Tab(icon: Icon(Icons.healing), text: 'Tratamientos'),
            Tab(icon: Icon(Icons.medical_services), text: 'Diagnósticos'),
            Tab(icon: Icon(Icons.attach_file), text: 'Archivos'),
            Tab(icon: Icon(Icons.notes), text: 'Resumen'),
          ],
        ),
      ),
      body: ResponsiveLayout(
        mobile: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Síntomas
              SymptomForm(
                initialSymptoms: _symptoms,
                onSymptomsChanged: (symptoms) => setState(() => _symptoms = symptoms),
              ),

              // Tab 2: Medicamentos
              MedicationForm(
                initialMedications: _medications,
                onMedicationsChanged: (medications) => setState(() => _medications = medications),
              ),

              // Tab 3: Tratamientos
              TreatmentForm(
                initialTreatments: _treatments,
                onTreatmentsChanged: (treatments) => setState(() => _treatments = treatments),
              ),

              // Tab 4: Diagnósticos
              DiagnosisForm(
                initialDiagnoses: _diagnoses,
                onDiagnosesChanged: (diagnoses) => setState(() => _diagnoses = diagnoses),
              ),

              // Tab 5: Archivos adjuntos
              AttachmentWidget(
                initialAttachments: _attachments,
                onAttachmentsChanged: (attachments) => setState(() => _attachments = attachments),
              ),

              // Tab 6: Resumen y guardar
              _buildSummaryTab(),
            ],
          ),
        ),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Form(
      key: _formKey,
      child: ResponsiveContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left sidebar with navigation
            SizedBox(
              width: 280,
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Patient info header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              _patient!.name.isNotEmpty ? _patient!.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _patient!.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${_patient!.age} años • ${_patient!.gender}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Navigation tabs
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: [
                          _buildDesktopNavItem(0, Icons.sick, 'Síntomas', _symptoms.length),
                          _buildDesktopNavItem(1, Icons.medication, 'Medicamentos', _medications.length),
                          _buildDesktopNavItem(2, Icons.healing, 'Tratamientos', _treatments.length),
                          _buildDesktopNavItem(3, Icons.medical_services, 'Diagnósticos', _diagnoses.length),
                          _buildDesktopNavItem(4, Icons.attach_file, 'Archivos', _attachments.length),
                          _buildDesktopNavItem(5, Icons.notes, 'Resumen', 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content area
            Expanded(
              child: Card(
                margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Síntomas
                    _buildDesktopTabContent(
                      SymptomForm(
                        initialSymptoms: _symptoms,
                        onSymptomsChanged: (symptoms) => setState(() => _symptoms = symptoms),
                      ),
                    ),

                    // Tab 2: Medicamentos
                    _buildDesktopTabContent(
                      MedicationForm(
                        initialMedications: _medications,
                        onMedicationsChanged: (medications) => setState(() => _medications = medications),
                      ),
                    ),

                    // Tab 3: Tratamientos
                    _buildDesktopTabContent(
                      TreatmentForm(
                        initialTreatments: _treatments,
                        onTreatmentsChanged: (treatments) => setState(() => _treatments = treatments),
                      ),
                    ),

                    // Tab 4: Diagnósticos
                    _buildDesktopTabContent(
                      DiagnosisForm(
                        initialDiagnoses: _diagnoses,
                        onDiagnosesChanged: (diagnoses) => setState(() => _diagnoses = diagnoses),
                      ),
                    ),

                    // Tab 5: Archivos adjuntos
                    _buildDesktopTabContent(
                      AttachmentWidget(
                        initialAttachments: _attachments,
                        onAttachmentsChanged: (attachments) => setState(() => _attachments = attachments),
                      ),
                    ),

                    // Tab 6: Resumen y guardar
                    _buildDesktopTabContent(_buildSummaryTab()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopNavItem(int index, IconData icon, String title, int count) {
    final isSelected = _tabController.index == index;
    final isRequired = title == 'Síntomas' || title == 'Diagnósticos';
    final hasError = isRequired && count == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
          ? Theme.of(context).primaryColor.withAlpha((255 * 0.1).round())
          : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _tabController.animateTo(index),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: hasError
                    ? Theme.of(context).colorScheme.error
                    : isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: hasError
                        ? Theme.of(context).colorScheme.error
                        : isSelected
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                  ),
                ),
                if (title != 'Resumen')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: hasError
                        ? Theme.of(context).colorScheme.error
                        : count > 0
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withAlpha((255 * 0.3).round()),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTabContent(Widget child) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: child,
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Información del paciente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          _patient!.name.isNotEmpty ? _patient!.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _patient!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${_patient!.age} años • ${_patient!.gender}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Tel: ${_patient!.phone}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Peso y Precio
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg) *',
                    prefixIcon: Icon(Icons.monitor_weight),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Requerido';
                    if (double.tryParse(value!) == null) return 'Número inválido';
                    final weight = double.parse(value);
                    if (weight <= 0 || weight > 500) return 'Peso inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio (\$) *',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Requerido';
                    if (double.tryParse(value!) == null) return 'Número inválido';
                    final price = double.parse(value);
                    if (price < 0) return 'Precio inválido';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Observaciones
          TextFormField(
            controller: _observationsController,
            decoration: const InputDecoration(
              labelText: 'Observaciones (opcional)',
              prefixIcon: Icon(Icons.note_add),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Resumen de datos
          _buildDataSummary(),
          const SizedBox(height: 24),

          // Botones
          Column(
            children: [
              Row(
                children: [
                  // Expanded(
                  //   child: OutlinedButton.icon(
                  //     onPressed: _isLoading ? null : () => context.go('/patients/${widget.patientId}'),
                  //     icon: const Icon(Icons.arrow_back),
                  //     label: const Text('Volver al Historial'),
                  //   ),
                  // ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveConsultation,
                      child: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar Consulta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de la Consulta',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildSummaryCard('Síntomas', _symptoms, Icons.sick),
        const SizedBox(height: 8),

        _buildSummaryCard('Medicamentos', _medications.map((m) => '${m.name} - ${m.dosage}').toList(), Icons.medication),
        const SizedBox(height: 8),

        _buildSummaryCard('Tratamientos', _treatments, Icons.healing),
        const SizedBox(height: 8),

        _buildSummaryCard('Diagnósticos', _diagnoses, Icons.medical_services),
        const SizedBox(height: 8),

        _buildSummaryCard('Archivos', _attachments.map((a) => a.fileName).toList(), Icons.attach_file),
      ],
    );
  }

  Widget _buildSummaryCard(String title, List<String> items, IconData icon) {
    final isRequired = title == 'Síntomas' || title == 'Diagnósticos';
    final isEmpty = items.isEmpty;
    final hasError = isRequired && isEmpty;

    return Card(
      color: hasError
          ? Theme.of(context).colorScheme.errorContainer.withAlpha((255 * 0.3).round())
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: hasError
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title + (isRequired ? ' *' : ''),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: hasError
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasError
                        ? Theme.of(context).colorScheme.error
                        : isEmpty
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  hasError
                      ? Icons.error_outline
                      : isEmpty
                          ? Icons.radio_button_unchecked
                          : Icons.check_circle,
                  size: 20,
                  color: hasError
                      ? Theme.of(context).colorScheme.error
                      : isEmpty
                          ? Colors.grey
                          : Colors.green,
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 2),
                child: Text(
                  '• $item',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              if (items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    '... y ${items.length - 3} más',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ] else
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Text(
                  hasError ? 'Requerido' : 'Sin elementos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasError
                        ? Theme.of(context).colorScheme.error
                        : Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontWeight: hasError ? FontWeight.w500 : null,
                  ),
                ),
              ),
          ],
        ),
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
              const Text('Errores de validación:', style: TextStyle(fontWeight: FontWeight.bold)),
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
        symptoms: _symptoms,
        medications: _medications,
        treatments: _treatments,
        diagnoses: _diagnoses,
        weight: double.parse(_weightController.text),
        observations: _observationsController.text.trim().isEmpty ? null : _observationsController.text.trim(),
        attachments: _attachments,
        price: double.parse(_priceController.text),
      );

      // Save consultation to database
      final savedConsultation = await ref.read(consultationProvider.notifier).addConsultation(consultation);

      // Generate PDF
      await _generateAndSavePDF(savedConsultation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consulta guardada y PDF generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form and navigate back
        _clearForm();
        context.go('/patients/${widget.patientId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar consulta: $e'),
            backgroundColor: Colors.red,
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
        await ref.read(settingsProvider.notifier).updateSettings(doctorSettings);
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

      // Save PDF to storage
      final fileName = 'Receta_${_patient!.name}_${consultation.date.millisecondsSinceEpoch}.pdf';
      final pdfPath = await pdfService.savePDFToStorage(pdfBytes, fileName);

      // Update consultation with PDF path
      final updatedConsultation = consultation.copyWith(pdfPath: pdfPath);
      await ref.read(consultationProvider.notifier).updateConsultation(updatedConsultation);

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
              content: Text('El archivo${fileType != null ? ' $fileType' : ''} no existe'),
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
        // Fallback para otras plataformas o mobile
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
            content: Text('Error al abrir${fileType != null ? ' $fileType' : ' archivo'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _weightController.clear();
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
    _tabController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _observationsController.dispose();
    super.dispose();
  }
}