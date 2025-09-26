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
        maxWidth: ResponsiveUtils.isDesktop(context) ? 1000 : double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Diseño responsive para desktop
              if (ResponsiveUtils.isDesktop(context))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información personal (lado izquierdo)
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información Personal',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Nombre completo
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre completo *',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                  
                                ),
                                style: const TextStyle(fontSize: 16),
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
                                ],
                                validator: _validateName,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),

                              // Fecha de nacimiento
                              TextFormField(
                                controller: _birthDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de nacimiento *',
                                  prefixIcon: Icon(Icons.cake),
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                style: const TextStyle(fontSize: 16),
                                readOnly: true,
                                onTap: _selectBirthDate,
                                validator: _validateBirthDate,
                              ),
                              const SizedBox(height: 20),

                              // Género
                              DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: 'Género *',
                                  prefixIcon: Icon(Icons.wc),
                                  border: OutlineInputBorder(),
                                ),
                                style: const TextStyle(fontSize: 16),
                                items: ['Masculino', 'Femenino', 'Otro'].map((gender) {
                                  return DropdownMenuItem(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
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
                    ),
                    const SizedBox(width: 24),

                    // Información de contacto (lado derecho)
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información de Contacto',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Teléfono
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Teléfono (opcional)',
                                  prefixIcon: Icon(Icons.phone),
                                  border: OutlineInputBorder(),
                                  
                                  helperText: 'Solo números, guiones, paréntesis y espacios',
                                ),
                                style: const TextStyle(fontSize: 16),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                                ],
                                validator: _validatePhone,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email (opcional)',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                  
                                ),
                                style: const TextStyle(fontSize: 16),
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Diseño móvil/tablet (original)
                ...[
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
                            ],
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
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
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
                              labelText: 'Teléfono (opcional)',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                              
                              helperText: 'Solo números, guiones, paréntesis y espacios',
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
                              
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

              SizedBox(height: ResponsiveUtils.isDesktop(context) ? 32 : 24),

              // Botones
              if (ResponsiveUtils.isDesktop(context))
                // Botones para desktop - más centrados y proporcionales
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.go('/patients'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _savePatient,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEditing ? 'Actualizar' : 'Guardar',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                )
              else
                // Botones para móvil/tablet - diseño original
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.go('/patients'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isLoading ? null : _savePatient,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
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
    // Verificar que solo contenga letras y espacios
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(value.trim())) {
      return 'El nombre solo puede contener letras y espacios';
    }
    // Verificar que no tenga múltiples espacios consecutivos
    if (value.trim().contains(RegExp(r'\s{2,}'))) {
      return 'El nombre no puede tener espacios consecutivos';
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
    // El teléfono ahora es opcional
    if (value == null || value.trim().isEmpty) {
      return null;
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
      final name = _nameController.text.trim();

      // Check for duplicate names
      final nameExists = await ref.read(patientProvider.notifier).checkPatientNameExists(
        name,
        excludeId: widget.patient?.id,
      );

      if (nameExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ya existe un paciente con el nombre "$name".\nPor favor, use un nombre diferente.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final age = _calculateAge(_selectedBirthDate!);

      final patient = Patient(
        id: widget.patient?.id,
        name: name,
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
            content: Text(
              widget.patient != null
                  ? 'Paciente actualizado correctamente'
                  : 'Paciente agregado correctamente',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to patient's consultation page if editing, otherwise to patients list
        if (widget.patient != null) {
          context.go('/patients/${widget.patient!.id}');
        } else {
          context.go('/patients');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: $e',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            SnackBar(
              content: const Text(
                'Paciente eliminado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/patients');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al eliminar: $e',
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