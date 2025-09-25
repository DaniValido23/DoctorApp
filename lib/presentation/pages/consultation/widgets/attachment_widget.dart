import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:doctor_app/data/models/attachment.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/services/file_organization_service.dart';

class AttachmentWidget extends StatefulWidget {
  final List<Attachment> initialAttachments;
  final Function(List<Attachment>) onAttachmentsChanged;
  final Patient? patient;
  final DateTime? consultationDate;

  const AttachmentWidget({
    super.key,
    required this.initialAttachments,
    required this.onAttachmentsChanged,
    this.patient,
    this.consultationDate,
  });

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  late List<Attachment> _attachments;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.initialAttachments);
  }

  Future<void> _pickFiles() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: true,
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          if (file.path != null) {
            await _saveFile(file);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFile(PlatformFile file) async {
    try {
      String destinationPath;

      if (widget.patient != null && widget.consultationDate != null) {
        // Save to consultation folder
        destinationPath =
            await FileOrganizationService.copyFileToConsultationFolder(
              widget.patient!,
              widget.consultationDate!,
              file.path!,
            );
      } else {
        // Fallback to old behavior for compatibility
        final appDir = await getApplicationDocumentsDirectory();
        final attachmentsDir = Directory('${appDir.path}/attachments');

        if (!await attachmentsDir.exists()) {
          await attachmentsDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_${file.name}';
        destinationPath = '${attachmentsDir.path}/$uniqueFileName';

        final sourceFile = File(file.path!);
        await sourceFile.copy(destinationPath);
      }

      // Crear objeto Attachment
      final attachment = Attachment(
        fileName: file.name,
        filePath: destinationPath,
        fileType: path.extension(file.name).toLowerCase(),
        uploadedAt: DateTime.now(),
      );

      setState(() {
        _attachments.add(attachment);
      });

      widget.onAttachmentsChanged(_attachments);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo "${file.name}" agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeAttachment(int index) async {
    final attachment = _attachments[index];

    try {
      // Eliminar archivo físico
      final file = File(attachment.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _attachments.removeAt(index);
      });

      widget.onAttachmentsChanged(_attachments);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo "${attachment.fileName}" eliminado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista scrollable de archivos adjuntos
        Expanded(
          child: _attachments.isEmpty
              ? _buildEmptyState()
              : _buildCompactAttachmentsList(),
        ),

        // Botón para agregar archivos en la parte inferior
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickFiles,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue,),
                    )
                  : const Icon(Icons.add, color: Colors.blue),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
              ),
              label: const Text(
                'Agregar Estudio',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_file_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Sin estudios médicos',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agregar documentos o imágenes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAttachmentsList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Contador de archivos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_attachments.length} estudio${_attachments.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista compacta de archivos
          ...List.generate(_attachments.length, (index) {
            final attachment = _attachments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              elevation: 1,
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: _getFileTypeColor(attachment.fileType),
                  child: Icon(
                    _getFileTypeIcon(attachment.fileType),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  attachment.fileName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${attachment.fileType.toUpperCase()} • ${_formatCompactDate(attachment.uploadedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  onPressed: () => _showDeleteDialog(index, attachment.fileName),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }


  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf_sharp;
      case '.png':
      case '.jpg':
      case '.jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case '.pdf':
        return Colors.red.shade500;
      case '.png':
      case '.jpg':
      case '.jpeg':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatCompactDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }

  Future<void> _showDeleteDialog(int index, String fileName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Archivo'),
        content: Text(
          '¿Eliminar "$fileName"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _removeAttachment(index);
    }
  }
}


