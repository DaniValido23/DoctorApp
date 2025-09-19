import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:doctor_app/services/pdf_service.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/data/models/consultation.dart';
import 'package:doctor_app/presentation/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class PDFPreviewPage extends ConsumerStatefulWidget {
  final Patient patient;
  final Consultation consultation;

  const PDFPreviewPage({
    super.key,
    required this.patient,
    required this.consultation,
  });

  @override
  ConsumerState<PDFPreviewPage> createState() => _PDFPreviewPageState();
}

class _PDFPreviewPageState extends ConsumerState<PDFPreviewPage> {
  final PDFService _pdfService = PDFService();
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generatePDF();
  }

  Future<void> _generatePDF() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final settingsAsync = ref.read(settingsProvider);

      if (settingsAsync.isLoading) {
        setState(() {
          _error = 'Cargando configuraciones del doctor...';
          _isLoading = false;
        });
        return;
      }

      if (settingsAsync.hasError) {
        setState(() {
          _error = 'Error al cargar configuraciones: ${settingsAsync.error}';
          _isLoading = false;
        });
        return;
      }

      final doctorSettings = settingsAsync.asData?.value;

      if (doctorSettings == null) {
        setState(() {
          _error = 'No se encontraron los datos del doctor. Configure su información primero.';
          _isLoading = false;
        });
        return;
      }

      final pdfBytes = await _pdfService.generatePrescriptionPDF(
        patient: widget.patient,
        consultation: widget.consultation,
        doctorSettings: doctorSettings,
      );

      setState(() {
        _pdfBytes = pdfBytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al generar el PDF: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _printPDF() async {
    if (_pdfBytes == null) return;

    try {
      await _pdfService.printPDF(
        _pdfBytes!,
        'Receta_${widget.patient.name}_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al imprimir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePDF() async {
    if (_pdfBytes == null) return;

    try {
      await _pdfService.sharePDF(
        _pdfBytes!,
        'Receta_${widget.patient.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePDF() async {
    if (_pdfBytes == null) return;

    try {
      final fileName = 'Receta_${widget.patient.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = await _pdfService.savePDFToStorage(_pdfBytes!, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF guardado en: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa de Receta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePDF,
              tooltip: 'Guardar PDF',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePDF,
              tooltip: 'Compartir PDF',
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _printPDF,
              tooltip: 'Imprimir',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generatePDF,
            tooltip: 'Regenerar PDF',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generando PDF...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generatePDF,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_pdfBytes == null) {
      return const Center(
        child: Text('No se pudo generar el PDF'),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: PdfPreview(
        build: (format) => _pdfBytes!,
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canDebug: false,
        canChangeOrientation: false,
        maxPageWidth: 700,
        pdfFileName: 'Receta_${widget.patient.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.save),
            onPressed: (context, build, pageFormat) => _savePDF(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_pdfBytes == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _savePDF,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _sharePDF,
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _printPDF,
                icon: const Icon(Icons.print),
                label: const Text('Imprimir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}