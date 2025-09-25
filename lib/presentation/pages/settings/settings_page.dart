import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:doctor_app/core/widgets/custom_drawer.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'package:doctor_app/data/models/doctor_settings.dart';
import 'package:doctor_app/core/utils/utils.dart';
import 'dart:io';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _titlesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctorSettings();
    });
  }

  void _loadDoctorSettings() {
    final settings = ref.read(settingsProvider);
    settings.whenData((doctorSettings) {
      if (doctorSettings != null) {
        _phoneController.text = doctorSettings.phone ?? '';
        _addressController.text = doctorSettings.address ?? '';
        _titlesController.text = doctorSettings.titles ?? '';
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _titlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seedingStatus = ref.watch(seedingProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
      ),
      drawer: const CustomDrawer(),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, seedingStatus, settingsAsync),
        desktop: _buildDesktopLayout(context, seedingStatus, settingsAsync),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, SeedingStatus seedingStatus, AsyncValue<DoctorSettings?> settingsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Configuración del Doctor'),
          const SizedBox(height: 16),
          settingsAsync.when(
            data: (settings) => settings != null
                ? _buildDoctorConfigCard(context, settings, isMobile: true)
                : _buildErrorCard(context, 'No se encontró configuración del doctor'),
            loading: () => _buildLoadingCard(context),
            error: (error, stack) => _buildErrorCard(context, error.toString()),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'Datos de Prueba'),
          const SizedBox(height: 16),
          _buildSeedingCard(context, seedingStatus, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, SeedingStatus seedingStatus, AsyncValue<DoctorSettings?> settingsAsync) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Configuración del Doctor'),
            const SizedBox(height: 24),
            settingsAsync.when(
              data: (settings) => settings != null
                  ? _buildDoctorConfigCard(context, settings, isMobile: false)
                  : _buildErrorCard(context, 'No se encontró configuración del doctor'),
              loading: () => _buildLoadingCard(context),
              error: (error, stack) => _buildErrorCard(context, error.toString()),
            ),
            const SizedBox(height: 40),
            _buildSectionTitle(context, 'Datos de Prueba'),
            const SizedBox(height: 24),
            _buildSeedingCard(context, seedingStatus, isMobile: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSeedingCard(BuildContext context, SeedingStatus seedingStatus, {required bool isMobile}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.data_usage,
                  color: Theme.of(context).colorScheme.primary,
                  size: isMobile ? 24 : 28,
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos de Prueba',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Poblar la base de datos con información ficticia para testing',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 14 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),

            // Estado actual
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: seedingStatus.hasSeedData
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: seedingStatus.hasSeedData
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    seedingStatus.hasSeedData ? Icons.check_circle : Icons.info,
                    color: seedingStatus.hasSeedData ? Colors.green[700] : Colors.grey[600],
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      seedingStatus.hasSeedData
                          ? 'Base de datos contiene datos de prueba (20 pacientes, 66 consultas)'
                          : 'Base de datos sin datos de prueba',
                      style: TextStyle(
                        color: seedingStatus.hasSeedData ? Colors.green[700] : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 14 : 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Mensaje de error si existe
            if (seedingStatus.state == SeedingState.error) ...[
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: isMobile ? 18 : 20),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Error: ${seedingStatus.errorMessage}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref.read(seedingProvider.notifier).clearError(),
                      icon: Icon(Icons.close, size: isMobile ? 18 : 20),
                      color: Colors.red[700],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],

            // Botones de acción separados
            Row(
              children: [
                // Botón Crear Datos
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: seedingStatus.state == SeedingState.seeding
                        ? null
                        : () => ref.read(seedingProvider.notifier).seedDatabase(),
                    icon: seedingStatus.state == SeedingState.seeding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add_box),
                    label: Text(seedingStatus.state == SeedingState.seeding
                        ? 'Creando...'
                        : 'Crear Datos'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 16,
                        horizontal: isMobile ? 12 : 16,
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                // Botón Eliminar Datos
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: seedingStatus.state == SeedingState.clearing
                        ? null
                        : () {
                            appLogger.d('DEBUG: Botón eliminar datos presionado');
                            ref.read(seedingProvider.notifier).clearSeedData();
                          },
                    icon: seedingStatus.state == SeedingState.clearing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.delete),
                    label: Text(seedingStatus.state == SeedingState.clearing
                        ? 'Eliminando...'
                        : 'Eliminar Datos'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 16,
                        horizontal: isMobile ? 12 : 16,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Información adicional
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Crear: Genera 20 pacientes con múltiples consultas (2-6 por paciente)\nEliminar: Borra permanentemente todos los datos de prueba',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: isMobile ? 12 : 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDoctorConfigCard(BuildContext context, DoctorSettings settings, {required bool isMobile}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 24 : 28,
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Text(
                      'Información del Doctor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 18 : null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 20 : 24),

              // Logo section
              _buildLogoSection(context, settings, isMobile),
              SizedBox(height: isMobile ? 20 : 24),

              // Doctor info (read-only)
              _buildReadOnlyField(context, 'Nombre del Doctor', 'Dr. José Luis Martínez', isMobile),
              SizedBox(height: isMobile ? 12 : 16),

              _buildReadOnlyField(context, 'Escuela de Medicina', 'Universidad Nacional Autónoma de México (UNAM)', isMobile),
              SizedBox(height: isMobile ? 12 : 16),

              _buildReadOnlyField(context, 'Especialidad', settings.specialty, isMobile),
              SizedBox(height: isMobile ? 12 : 16),

              _buildReadOnlyField(context, 'Número de Licencia', settings.licenseNumber, isMobile),
              SizedBox(height: isMobile ? 20 : 24),

              // Editable fields
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono del Consultorio',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: isMobile ? 16 : 20),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección del Consultorio',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: isMobile ? 16 : 20),

              TextFormField(
                controller: _titlesController,
                decoration: const InputDecoration(
                  labelText: 'Títulos, Diplomados y Especialidades',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Cardiólogo, Diplomado en Medicina Interna, Especialista en...',
                ),
                maxLines: 3,
              ),
              SizedBox(height: isMobile ? 20 : 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveDoctorSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Configuración'),
                  style: ElevatedButton.styleFrom(
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
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, DoctorSettings settings, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logo del Consultorio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Logo preview
              Container(
                width: isMobile ? 80 : 100,
                height: isMobile ? 80 : 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: settings.logoPath != null && settings.logoPath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(settings.logoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildLogoPlaceholder(isMobile);
                          },
                        ),
                      )
                    : _buildLogoPlaceholder(isMobile),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Seleccionar Logo'),
                    ),
                    const SizedBox(height: 8),
                    if (settings.logoPath != null && settings.logoPath!.isNotEmpty)
                      TextButton.icon(
                        onPressed: _removeLogo,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Eliminar Logo', style: TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Formatos: PNG, JPG, JPEG',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: isMobile ? 32 : 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'Logo',
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 12 : 14,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red[700], size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar configuración',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(settingsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final logoPath = result.files.single.path!;
        await _updateLogoPath(logoPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeLogo() async {
    await _updateLogoPath(null);
  }

  Future<void> _updateLogoPath(String? logoPath) async {
    final settingsAsync = ref.read(settingsProvider);
    settingsAsync.whenData((currentSettings) async {
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(logoPath: logoPath);
        await ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
      }
    });
  }

  Future<void> _saveDoctorSettings() async {
    try {
      final settingsAsync = ref.read(settingsProvider);
      settingsAsync.whenData((currentSettings) async {
        if (currentSettings != null) {
          final updatedSettings = currentSettings.copyWith(
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            titles: _titlesController.text.trim().isEmpty ? null : _titlesController.text.trim(),
          );

          await ref.read(settingsProvider.notifier).updateSettings(updatedSettings);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Configuración guardada correctamente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar configuración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}