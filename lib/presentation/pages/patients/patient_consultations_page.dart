import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
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
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/patients'),
              tooltip: 'Ir a inicio',
            ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "delete_patient",
            onPressed: _deletePatient,
            backgroundColor: Colors.red,
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Paciente'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "edit_patient",
            onPressed: _editPatient,
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.edit),
            label: const Text('Editar Paciente'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "new_consultation",
            onPressed: () => context.go('/patients/${widget.patientId}/consultation'),
            icon: const Icon(Icons.add),
            label: const Text('Nueva Consulta'),
          ),
        ],
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
        childAspectRatio: 0.85,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showConsultationDetails(consultation),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fecha de la consulta (título principal)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 22,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd/MM/yyyy').format(consultation.date),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Síntomas
              if (consultation.symptoms.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Síntomas:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  consultation.symptoms.take(2).join(', ') +
                  (consultation.symptoms.length > 2 ? '...' : ''),
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Diagnósticos
              if (consultation.diagnoses.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Diagnóstico:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  consultation.diagnoses.join(', '),
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],

              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon(
                    //   Icons.attach_money,
                    //   size: 24,
                    //   color: Colors.green[700],
                    // ),
                    // const SizedBox(width: 8),
                    Text(
                      '$consultation.price',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Archivos adjuntos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PDF generado
                  if (consultation.pdfPath != null)
                    InkWell(
                      onTap: () => _openPDF(consultation),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 20,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Receta',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Indicador de documentos adjuntos
                  if (consultation.attachments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 20,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${consultation.attachments.length} ${consultation.attachments.length == 1 ? 'archivo' : 'archivos'}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
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
    );
  }

  Widget _buildDesktopConsultationCard(Consultation consultation) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showConsultationDetails(consultation),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Fecha de la consulta (título principal)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(consultation.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Información médica
              Column(
                children: [
                  // Síntomas
                  if (consultation.symptoms.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Síntomas',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      consultation.symptoms.take(2).join(', ') +
                      (consultation.symptoms.length > 2 ? '...' : ''),
                      style: theme.textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Diagnósticos
                  if (consultation.diagnoses.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Diagnóstico',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      consultation.diagnoses.join(', '),
                      style: theme.textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),

              const Spacer(),

              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon(
                    //   Icons.attach_money,
                    //   size: 20,
                    //   color: Colors.green[700],
                    // ),
                    // const SizedBox(width: 6),
                    Text(
                      '\$${NumberFormat('#,###', 'en_US').format(consultation.price)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Archivos adjuntos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PDF generado
                  if (consultation.pdfPath != null)
                    InkWell(
                      onTap: () => _openPDF(consultation),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        margin: const EdgeInsets.only(right: 8),
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
                              size: 16,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Receta',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Indicador de documentos adjuntos
                  if (consultation.attachments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${consultation.attachments.length} ${consultation.attachments.length == 1 ? 'archivo' : 'archivos'}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
                      '\$${NumberFormat('#,###', 'en_US').format(consultation.price)}',
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
                                      'Receta',
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
        // Cerrar el diálogo de detalles de la consulta
        navigator.pop();

        await _loadData();

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Consulta eliminada correctamente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
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

  void _editPatient() {
    if (_patient != null) {
      context.go('/patients/add', extra: _patient);
    }
  }

  Future<void> _deletePatient() async {
    if (_patient == null) return;

    final confirmed = await _showDeletePatientDialog();
    if (!confirmed) return;

    try {
      await ref.read(patientProvider.notifier).removePatient(_patient!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_patient!.name} ha sido eliminado',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );

        // Navigate back to patients list
        context.go('/patients');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar paciente: $e',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showDeletePatientDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: '¿Estás seguro de que deseas eliminar a '),
              TextSpan(
                text: _patient?.name ?? 'este paciente',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nEsta acción no se puede deshacer y se eliminarán también todas las consultas asociadas.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }
}

class _ConsultationDetailsDialog extends ConsumerStatefulWidget {
  final Consultation consultation;
  final Function(String, String?) onOpenFile;
  final Function(Consultation) onDeleteConsultation;

  const _ConsultationDetailsDialog({
    required this.consultation,
    required this.onOpenFile,
    required this.onDeleteConsultation,
  });

  @override
  ConsumerState<_ConsultationDetailsDialog> createState() => _ConsultationDetailsDialogState();
}

class _ConsultationDetailsDialogState extends ConsumerState<_ConsultationDetailsDialog> {
  late List<Attachment> _availableAttachments;
  String? _availablePdfPath;

  @override
  void initState() {
    super.initState();
    _availableAttachments = List.from(widget.consultation.attachments);
    _availablePdfPath = widget.consultation.pdfPath;
    _checkFileAvailability();
  }

  Future<void> _checkFileAvailability() async {
    // Check PDF availability
    if (_availablePdfPath != null && !await File(_availablePdfPath!).exists()) {
      setState(() {
        _availablePdfPath = null;
      });
    }

    // Check attachments availability
    final List<Attachment> availableAttachments = [];
    for (final attachment in _availableAttachments) {
      if (await File(attachment.filePath).exists()) {
        availableAttachments.add(attachment);
      }
    }

    if (availableAttachments.length != _availableAttachments.length) {
      setState(() {
        _availableAttachments = availableAttachments;
      });
    }
  }

  Future<void> _openFileWithErrorHandling(String filePath, String? fileType, {String? fileName}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _showFileNotFoundDialog(fileName ?? 'El archivo');
        await _checkFileAvailability(); // Refresh file list
        return;
      }
      widget.onOpenFile(filePath, fileType);
    } catch (e) {
      _showErrorDialog('Error al abrir el archivo', e.toString());
    }
  }

  void _showFileNotFoundDialog(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Archivo no encontrado'),
          ],
        ),
        content: Text(
          '$fileName no se encuentra en el sistema.\n\n'
          'Es posible que haya sido eliminado o movido. '
          'El archivo será removido de la lista.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Responsive sizing
    final dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95  // Use most of screen width on mobile
        : (isTablet
            ? MediaQuery.of(context).size.width * 0.85  // Use more space on tablet
            : MediaQuery.of(context).size.width * 0.65); // Keep current desktop size

    final dialogHeight = isMobile
        ? MediaQuery.of(context).size.height * 0.9   // Use most of screen height on mobile
        : (isTablet
            ? MediaQuery.of(context).size.height * 0.8  // Use more space on tablet
            : MediaQuery.of(context).size.height * 0.95); // Increased desktop size

    final maxWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.98
        : (isTablet
            ? MediaQuery.of(context).size.width * 0.88
            : MediaQuery.of(context).size.width * 0.68);

    final maxHeight = isMobile
        ? MediaQuery.of(context).size.height * 0.95
        : (isTablet
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height * 0.85);

    return Dialog(
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: Theme.of(context).colorScheme.primary,
                  size: isMobile ? 24 : 28,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Detalles de la Consulta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 20 : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              DateFormat('dd/MM/yyyy - HH:mm').format(widget.consultation.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: isMobile ? 14 : null,
              ),
            ),
            Divider(height: isMobile ? 24 : 32),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Signos vitales
                    if (_hasVitalSigns(widget.consultation)) ...[
                      _buildVitalSignsTable(context, widget.consultation, isMobile),
                      SizedBox(height: isMobile ? 20 : 24),
                    ],

                    // Información médica en tabla de dos columnas
                    _buildMedicalInfoTable(context, widget.consultation, isMobile),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Información básica en tabla de dos columnas
                    _buildBasicInfoTable(context, widget.consultation, isMobile),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Archivos adjuntos y receta
                    if (_availableAttachments.isNotEmpty || _availablePdfPath != null) ...[
                      _buildAttachmentsSection(context, widget.consultation, isMobile),
                      SizedBox(height: isMobile ? 16 : 24),
                    ],
                  ],
                ),
              ),
            ),

            // Delete button at the bottom
            const Divider(),
            SizedBox(height: isMobile ? 8 : 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(context),
                icon: Icon(Icons.delete, color: Colors.red[700]),
                label: const Text('Eliminar Consulta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[300]!),
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : 16,
                    horizontal: isMobile ? 16 : 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTable(BuildContext context, Consultation consultation, bool isMobile) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Adicional',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 16 : 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                // Información económica
                _buildTableRow('Precio:', '\$${NumberFormat('#,###', 'en_US').format(widget.consultation.price)}', isMobile),

                // Observaciones
                if (widget.consultation.observations?.isNotEmpty == true)
                  _buildTableRow('Observaciones:', widget.consultation.observations!, isMobile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoTable(BuildContext context, Consultation consultation, bool isMobile) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Médica',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 16 : 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Síntomas:', widget.consultation.symptoms.join(', '), isMobile),
                if (widget.consultation.medications.isNotEmpty)
                  _buildTableRow('Medicamentos:', _formatMedications(widget.consultation.medications), isMobile),
                _buildTableRow('Diagnósticos:', widget.consultation.diagnoses.join(', '), isMobile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, bool isMobile) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, right: 16.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 14 : 15,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            value.isEmpty ? 'No especificado' : value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatMedications(List<Medication> medications) {
    return medications.map((med) => '${med.name} - ${med.dosage} - ${med.frequency}').join('\n');
  }

  bool _hasVitalSigns(Consultation consultation) {
    return consultation.bodyTemperature != null ||
           consultation.bloodPressureSystolic != null ||
           consultation.bloodPressureDiastolic != null ||
           consultation.oxygenSaturation != null ||
           consultation.weight != null ||
           consultation.height != null;
  }

  Widget _buildVitalSignsTable(BuildContext context, Consultation consultation, bool isMobile) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signos Vitales',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 16 : 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                if (consultation.bodyTemperature != null)
                  _buildTableRow('Temperatura:', '${consultation.bodyTemperature!.toStringAsFixed(1)}°C', isMobile),
                if (consultation.bloodPressureSystolic != null && consultation.bloodPressureDiastolic != null)
                  _buildTableRow('Presión arterial:', '${consultation.bloodPressureSystolic}/${consultation.bloodPressureDiastolic} mmHg', isMobile),
                if (consultation.oxygenSaturation != null)
                  _buildTableRow('Saturación O2:', '${consultation.oxygenSaturation!.toStringAsFixed(1)}%', isMobile),
                if (consultation.weight != null)
                  _buildTableRow('Peso:', '${consultation.weight!.toStringAsFixed(1)} kg', isMobile),
                if (consultation.height != null)
                  _buildTableRow('Altura:', '${consultation.height!.toStringAsFixed(1)} cm', isMobile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context, Consultation consultation, bool isMobile) {
    final totalFiles = _availableAttachments.length + (_availablePdfPath != null ? 1 : 0);

    if (totalFiles == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Archivos ($totalFiles)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : 18,
          ),
        ),
        const SizedBox(height: 12),

        // Lista de archivos en chips/botones moderados
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            // PDF de receta si existe
            if (_availablePdfPath != null)
              InkWell(
                onTap: () => _openFileWithErrorHandling(_availablePdfPath!, 'PDF', fileName: 'Receta Médica'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 10,
                  ),
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
                        size: isMobile ? 16 : 18,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Receta Médica',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.open_in_new,
                        size: isMobile ? 14 : 16,
                        color: Colors.red[700],
                      ),
                    ],
                  ),
                ),
              ),

            // Archivos adjuntos
            ..._availableAttachments.map((attachment) => InkWell(
              onTap: () => _openFileWithErrorHandling(attachment.filePath, attachment.fileType, fileName: attachment.fileName),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: isMobile ? 16 : 18,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? 120 : 150,
                      ),
                      child: Text(
                        attachment.fileName,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.open_in_new,
                      size: isMobile ? 14 : 16,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Consulta'),
        content: Text('¿Estás seguro de que deseas eliminar esta consulta del ${DateFormat('dd/MM/yyyy').format(widget.consultation.date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeleteConsultation(widget.consultation);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}