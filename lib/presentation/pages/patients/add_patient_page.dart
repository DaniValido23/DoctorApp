import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/presentation/providers/patient_provider.dart';
import 'package:doctor_app/core/utils/responsive_utils.dart';

class AddPatientPage extends ConsumerStatefulWidget {
  final Patient? patient; // Para edición (opcional)

  const AddPatientPage({super.key, this.patient});

  @override
  ConsumerState<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends ConsumerState<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();

  String _selectedGender = 'Masculino';
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.patient != null) {
      final patient = widget.patient!;
      _nameController.text = patient.name;
      _phoneController.text = patient.phone;
      _emailController.text = patient.email ?? '';
      _selectedGender = patient.gender;
      _selectedBirthDate = patient.birthDate;
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(patient.birthDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Paciente' : 'Agregar Paciente'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: ResponsiveUtils.isDesktop(context) ? 800 : double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Información personal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Personal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nombre completo
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: _validateName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento *',
                          prefixIcon: Icon(Icons.cake),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: _selectBirthDate,
                        validator: _validateBirthDate,
                      ),
                      const SizedBox(height: 16),

                      // Género
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Género *',
                          prefixIcon: Icon(Icons.wc),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Masculino', 'Femenino', 'Otro'].map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                        validator: (value) => value == null ? 'Selecciona un género' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información de contacto
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Contacto',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Teléfono
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono *',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                          hintText: 'Ej: +1234567890',
                          helperText: 'Varios pacientes pueden compartir el mismo teléfono',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                        ],
                        validator: _validatePhone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (opcional)',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          hintText: 'ejemplo@email.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Información calculada
              // if (_selectedBirthDate != null)
              //   Card(
              //     color: Theme.of(context).colorScheme.surfaceContainerHighest,
              //     child: Padding(
              //       padding: const EdgeInsets.all(16),
              //       child: Column(
              //         children: [
              //           Row(
              //             children: [
              //               const Icon(Icons.info_outline),
              //               const SizedBox(width: 8),
              //               Text(
              //                 'Información calculada',
              //                 style: Theme.of(context).textTheme.titleSmall,
              //               ),
              //             ],
              //           ),
              //           const SizedBox(height: 8),
              //           Text(
              //             'Edad: ${_calculateAge(_selectedBirthDate!)} años',
              //             style: Theme.of(context).textTheme.bodyMedium,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.go('/patients'),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _savePatient,
                      child: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Actualizar' : 'Guardar'),
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedBirthDate = date;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (_selectedBirthDate == null) {
      return 'La fecha de nacimiento es obligatoria';
    }
    final age = _calculateAge(_selectedBirthDate!);
    if (age < 0) {
      return 'La fecha de nacimiento no puede ser futura';
    }
    if (age > 150) {
      return 'Edad no válida';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es obligatorio';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 7) {
      return 'El teléfono debe tener al menos 7 dígitos';
    }
    if (cleanPhone.length > 15) {
      return 'El teléfono no puede tener más de 15 dígitos';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email es opcional
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email no válido';
    }
    return null;
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final age = _calculateAge(_selectedBirthDate!);

      final patient = Patient(
        id: widget.patient?.id,
        name: _nameController.text.trim(),
        age: age,
        birthDate: _selectedBirthDate!,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        gender: _selectedGender,
        createdAt: widget.patient?.createdAt ?? DateTime.now(),
      );

      if (widget.patient != null) {
        await ref.read(patientProvider.notifier).updatePatient(patient);
      } else {
        await ref.read(patientProvider.notifier).addPatient(patient);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.patient != null
                ? 'Paciente actualizado correctamente'
                : 'Paciente agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/patients');
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    if (widget.patient?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Paciente'),
        content: Text('¿Estás seguro de que deseas eliminar a ${widget.patient!.name}?'),
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

    if (confirmed == true) {
      try {
        await ref.read(patientProvider.notifier).removePatient(widget.patient!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente eliminado')),
          );
          context.go('/patients');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}