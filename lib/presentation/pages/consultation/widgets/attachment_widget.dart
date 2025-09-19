import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:doctor_app/data/models/attachment.dart';

class AttachmentWidget extends StatefulWidget {
  final List<Attachment> initialAttachments;
  final Function(List<Attachment>) onAttachmentsChanged;

  const AttachmentWidget({
    super.key,
    required this.initialAttachments,
    required this.onAttachmentsChanged,
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
      // Obtener directorio de documentos de la app
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory('${appDir.path}/attachments');

      // Crear directorio si no existe
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      // Generar nombre único para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.name);
      final uniqueFileName = '${timestamp}_${file.name}';
      final destinationPath = '${attachmentsDir.path}/$uniqueFileName';

      // Copiar archivo al directorio de la app
      final sourceFile = File(file.path!);
      await sourceFile.copy(destinationPath);

      // Crear objeto Attachment
      final attachment = Attachment(
        fileName: file.name,
        filePath: destinationPath,
        fileType: extension.toLowerCase(),
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
            backgroundColor: Colors.orange,
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

  Future<void> _previewFile(Attachment attachment) async {
    showDialog(
      context: context,
      builder: (context) => _FilePreviewDialog(attachment: attachment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

          // Lista de archivos adjuntos
          if (_attachments.isEmpty)
            _buildEmptyState()
          else
            _buildAttachmentsList(),
            ],
          ),
        ),
        // FloatingActionButton para agregar archivos
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _isLoading ? null : _pickFiles,
            tooltip: 'Adjuntar archivos',
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.attach_file),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_file_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay archivos adjuntos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón + para agregar documentos, imágenes o PDFs',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la lista
          Row(
            children: [
              Text(
                'Archivos Adjuntos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_attachments.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de archivos
          Expanded(
            child: ListView.builder(
              itemCount: _attachments.length,
              itemBuilder: (context, index) {
                final attachment = _attachments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getFileTypeColor(attachment.fileType),
                      child: Icon(
                        _getFileTypeIcon(attachment.fileType),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      attachment.fileName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Tipo: ${attachment.fileType.toUpperCase()}'),
                        Text(
                          'Agregado: ${_formatDate(attachment.uploadedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => _previewFile(attachment),
                          tooltip: 'Vista previa',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[400],
                          ),
                          onPressed: () => _showDeleteDialog(index, attachment.fileName),
                          tooltip: 'Eliminar archivo',
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf;
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
        return Colors.red;
      case '.png':
      case '.jpg':
      case '.jpeg':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showDeleteDialog(int index, String fileName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Archivo'),
        content: Text('¿Eliminar "$fileName"?\n\nEsta acción no se puede deshacer.'),
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

class _FilePreviewDialog extends StatelessWidget {
  final Attachment attachment;

  const _FilePreviewDialog({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(_getFileTypeIcon(attachment.fileType)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attachment.fileName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Preview content
            Expanded(
              child: _buildPreviewContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_isImageFile()) {
      return Center(
        child: Image.file(
          File(attachment.filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState('Error al cargar la imagen');
          },
        ),
      );
    } else if (_isPdfFile()) {
      return _buildPdfPreview();
    } else {
      return _buildUnsupportedFileType();
    }
  }

  Widget _buildPdfPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Vista previa de PDF',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'La vista previa de archivos PDF estará disponible próximamente',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            'Archivo: ${attachment.fileName}',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedFileType() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Vista previa no disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este tipo de archivo no admite vista previa',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.red[600]),
          ),
        ],
      ),
    );
  }

  bool _isImageFile() {
    final ext = attachment.fileType.toLowerCase();
    return ext == '.png' || ext == '.jpg' || ext == '.jpeg';
  }

  bool _isPdfFile() {
    return attachment.fileType.toLowerCase() == '.pdf';
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.png':
      case '.jpg':
      case '.jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}