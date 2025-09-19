import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/data/models/consultation.dart';
import 'package:doctor_app/data/models/medication.dart';
import 'package:doctor_app/data/models/attachment.dart';
import 'package:doctor_app/presentation/providers/patient_provider.dart';
import 'package:doctor_app/presentation/providers/consultation_provider.dart';
import 'package:doctor_app/core/utils/responsive_utils.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientConsultationsPage extends ConsumerStatefulWidget {
  final int patientId;

  const PatientConsultationsPage({super.key, required this.patientId});

  @override
  ConsumerState<PatientConsultationsPage> createState() => _PatientConsultationsPageState();
}

class _PatientConsultationsPageState extends ConsumerState<PatientConsultationsPage> {
  Patient? _patient;
  List<Consultation> _consultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final patient = await ref.read(patientProvider.notifier).getPatientById(widget.patientId);
      final consultations = await ref.read(consultationProvider.notifier).getConsultationsByPatientId(widget.patientId);

      if (mounted) {
        setState(() {
          _patient = patient;
          _consultations = consultations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se pudo cargar la información del paciente'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_patient!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/patients'),
            tooltip: 'Ir a inicio',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del paciente
          // _buildPatientHeader(),

          // Lista de consultas
          Expanded(
            child: _consultations.isEmpty
                ? _buildEmptyState()
                : _buildConsultationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/patients/${widget.patientId}/consultation'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Consulta'),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay consultas registradas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón "Nueva Consulta" para registrar la primera consulta',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationsList() {
    return ResponsiveLayout(
      mobile: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _consultations.length,
        itemBuilder: (context, index) {
          final consultation = _consultations[index];
          return _buildConsultationCard(consultation);
        },
      ),
      desktop: ResponsiveContainer(
        child: ResponsiveUtils.isLargeDesktop(context)
          ? _buildDesktopGrid()
          : _buildDesktopList(),
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridColumns(context, maxColumns: 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: _consultations.length,
      itemBuilder: (context, index) {
        final consultation = _consultations[index];
        return _buildDesktopConsultationCard(consultation);
      },
    );
  }

  Widget _buildDesktopList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _consultations.length,
      itemBuilder: (context, index) {
        final consultation = _consultations[index];
        return _buildWideConsultationCard(consultation);
      },
    );
  }

  Widget _buildConsultationCard(Consultation consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showConsultationDetails(consultation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Primera fila: Diagnóstico y Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Diagnóstico
                  Expanded(
                    child: Text(
                      consultation.diagnoses.isNotEmpty
                        ? consultation.diagnoses.join(', ')
                        : 'Sin diagnósticos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Fecha
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(consultation.date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Segunda fila: Precio y Documentos
              Row(
                children: [
                  // Precio
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '\$${consultation.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Documentos
                  Expanded(
                    child: Row(
                      children: [
                        // PDF generado
                        if (consultation.pdfPath != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => _openPDF(consultation),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      size: 16,
                                      color: Colors.red[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PDF',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Documentos adjuntos
                        if (consultation.attachments.isNotEmpty)
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: consultation.attachments.take(3).map((attachment) {
                                return InkWell(
                                  onTap: () => _openFile(attachment.filePath),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.attach_file,
                                          size: 12,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            attachment.fileName.length > 10
                                              ? '${attachment.fileName.substring(0, 10)}...'
                                              : attachment.fileName,
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Indicador de más documentos si hay más de 3
                        if (consultation.attachments.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${consultation.attachments.length - 3}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Icono para ver detalles
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopConsultationCard(Consultation consultation) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showConsultationDetails(consultation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primera fila: Diagnóstico y Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Diagnóstico
                  Expanded(
                    child: Text(
                      consultation.diagnoses.isNotEmpty
                        ? consultation.diagnoses.join(', ')
                        : 'Sin diagnósticos',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Fecha
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(consultation.date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Segunda fila: Precio y Documentos
              Row(
                children: [
                  // Precio
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '\$${consultation.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Documentos
                  Expanded(
                    child: Row(
                      children: [
                        // PDF generado
                        if (consultation.pdfPath != null)
                          InkWell(
                            onTap: () => _openPDF(consultation),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 12,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Indicador de documentos adjuntos
                        if (consultation.attachments.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 12,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${consultation.attachments.length}',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideConsultationCard(Consultation consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showConsultationDetails(consultation),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Primera fila: Diagnóstico y Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Diagnóstico
                  Expanded(
                    child: Text(
                      consultation.diagnoses.isNotEmpty
                        ? consultation.diagnoses.join(', ')
                        : 'Sin diagnósticos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Fecha
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(consultation.date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Segunda fila: Precio y Documentos
              Row(
                children: [
                  // Precio
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '\$${consultation.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Documentos
                  Expanded(
                    child: Row(
                      children: [
                        // PDF generado
                        if (consultation.pdfPath != null)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () => _openPDF(consultation),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      size: 18,
                                      color: Colors.red[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PDF Receta',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Documentos adjuntos
                        if (consultation.attachments.isNotEmpty)
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ...consultation.attachments.take(4).map((attachment) {
                                  return InkWell(
                                    onTap: () => _openFile(attachment.filePath),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attach_file,
                                            size: 14,
                                            color: Colors.blue[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              attachment.fileName.length > 15
                                                ? '${attachment.fileName.substring(0, 15)}...'
                                                : attachment.fileName,
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                // Indicador de más documentos si hay más de 4
                                if (consultation.attachments.length > 4)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '+${consultation.attachments.length - 4} más',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Icono para ver detalles
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showConsultationDetails(consultation),
                    tooltip: 'Ver detalles',
                    iconSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationDetails(Consultation consultation) {
    showDialog(
      context: context,
      builder: (context) => _ConsultationDetailsDialog(
        consultation: consultation,
        onOpenFile: _openFile,
        onDeleteConsultation: _deleteConsultation,
      ),
    );
  }

  Future<void> _openPDF(Consultation consultation) async {
    if (consultation.pdfPath == null) return;
    await _openFile(consultation.pdfPath!, 'PDF');
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

  Future<void> _deleteConsultation(Consultation consultation) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(consultationProvider.notifier).deleteConsultation(consultation.id!);

      if (mounted) {
        // Cerrar el diálogo si está abierto
        navigator.pop();

        // Recargar las consultas
        await _loadData();

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Consulta eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error al eliminar consulta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ConsultationDetailsDialog extends ConsumerWidget {
  final Consultation consultation;
  final Function(String, String?) onOpenFile;
  final Function(Consultation) onDeleteConsultation;

  const _ConsultationDetailsDialog({
    required this.consultation,
    required this.onOpenFile,
    required this.onDeleteConsultation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        height: MediaQuery.of(context).size.height * 0.6,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.68,
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detalles de la Consulta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[700]),
                  onPressed: () => _showDeleteDialog(context),
                  tooltip: 'Eliminar consulta',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('dd/MM/yyyy - HH:mm').format(consultation.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 32),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información básica
                    _buildDetailSection(
                      'Información General',
                      [
                        'Peso: ${consultation.weight.toStringAsFixed(1)} kg',
                        'Precio: \$${consultation.price.toStringAsFixed(2)}',
                        if (consultation.observations?.isNotEmpty == true)
                          'Observaciones: ${consultation.observations}',
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Síntomas
                    _buildDetailSection(
                      'Síntomas (${consultation.symptoms.length})',
                      consultation.symptoms,
                    ),
                    const SizedBox(height: 24),

                    // Medicamentos
                    if (consultation.medications.isNotEmpty) ...[
                      _buildMedicationSection(consultation.medications),
                      const SizedBox(height: 24),
                    ],

                    // Tratamientos
                    if (consultation.treatments.isNotEmpty) ...[
                      _buildDetailSection(
                        'Tratamientos (${consultation.treatments.length})',
                        consultation.treatments,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Diagnósticos
                    _buildDetailSection(
                      'Diagnósticos (${consultation.diagnoses.length})',
                      consultation.diagnoses,
                    ),

                    // Archivos adjuntos
                    if (consultation.attachments.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildAttachmentsSection(context, consultation.attachments),
                    ],

                    // Espaciado final
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Center(
            child: Text(
              'Sin elementos',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildMedicationSection(List<Medication> medications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medicamentos (${medications.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        ...medications.map((med) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                med.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Dosis: ${med.dosage}',
                style: const TextStyle(fontSize: 15, height: 1.3),
              ),
              const SizedBox(height: 4),
              Text(
                'Frecuencia: ${med.frequency}',
                style: const TextStyle(fontSize: 15, height: 1.3),
              ),
              if (med.instructions?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  'Instrucciones: ${med.instructions!}',
                  style: const TextStyle(fontSize: 15, height: 1.3),
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAttachmentsSection(BuildContext context, List<Attachment> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Archivos Adjuntos (${attachments.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        ...attachments.map((attachment) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onOpenFile(attachment.filePath, attachment.fileType),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.fileName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'Tipo: ${attachment.fileType}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Consulta'),
        content: Text('¿Estás seguro de que deseas eliminar esta consulta del ${DateFormat('dd/MM/yyyy').format(consultation.date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteConsultation(consultation);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}