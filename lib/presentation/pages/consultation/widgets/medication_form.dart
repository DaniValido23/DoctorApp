import 'package:flutter/material.dart';
import 'package:doctor_app/data/models/medication.dart';

class MedicationForm extends StatefulWidget {
  final List<Medication> initialMedications;
  final Function(List<Medication>) onMedicationsChanged;

  const MedicationForm({
    super.key,
    required this.initialMedications,
    required this.onMedicationsChanged,
  });

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  late List<Medication> _medications;
  final List<_MedicationRowControllers> _controllers = [];

  // Sugerencias comunes de medicamentos
  static const List<String> _commonMedications = [
    'Paracetamol',
    'Ibuprofeno',
    'Aspirina',
    'Amoxicilina',
    'Omeprazol',
    'Losartán',
    'Metformina',
    'Atorvastatina',
    'Amlodipino',
    'Levotiroxina',
    'Diclofenaco',
    'Acetaminofén',
    'Naproxeno',
    'Prednisona',
    'Furosemida',
    'Captopril',
    'Enalapril',
    'Simvastatina',
    'Ranitidina',
    'Ciprofloxacino',
    'Azitromicina',
    'Dexametasona',
    'Hidroclorotiazida',
    'Propranolol',
    'Digoxina',
  ];

  // Sugerencias comunes de dosis
  static const List<String> _commonDosages = [
    '100mg',
    '250mg',
    '500mg',
    '750mg',
    '1g',
    '1.5g',
    '2g',
    '5ml',
    '10ml',
    '15ml',
    '20ml',
    '50ml',
    '100ml',
    '1 tableta',
    '2 tabletas',
    '1/2 tableta',
    '1 cápsula',
    '2 cápsulas',
    '1 sobre',
    '1 ampolla',
    '2.5mg',
    '5mg',
    '10mg',
    '20mg',
    '25mg',
    '50mg',
  ];

  // Sugerencias comunes de frecuencia
  static const List<String> _commonFrequencies = [
    'Cada 4 horas',
    'Cada 6 horas',
    'Cada 8 horas',
    'Cada 12 horas',
    'Una vez al día',
    'Dos veces al día',
    'Tres veces al día',
    'Cuatro veces al día',
    'Cada 24 horas',
    'En ayunas',
    'Con las comidas',
    'Antes de dormir',
    'Al desayuno',
    'Al almuerzo',
    'A la cena',
    'Cada mañana',
    'Cada noche',
    'Solo por necesidad',
    'Cada 2 horas',
    'Cada 3 horas',
  ];

  // Sugerencias comunes de duración/instrucciones
  static const List<String> _commonInstructions = [
    '7 días',
    '10 días',
    '14 días',
    '21 días',
    '1 mes',
    '2 meses',
    '3 meses',
    'Con alimentos',
    'Sin alimentos',
    'Con abundante agua',
    'Antes de las comidas',
    'Después de las comidas',
    'En ayunas',
    'No masticar',
    'Disolver en agua',
    'Aplicar sobre la piel',
    'Hasta mejoría',
    'Según síntomas',
    'Solo si es necesario',
    'Continuar hasta nueva orden',
    'Suspender gradualmente',
    '5 días',
    '15 días',
    '30 días',
    '6 meses',
  ];


  @override
  void initState() {
    super.initState();
    _medications = List.from(widget.initialMedications);

    // Inicializar controllers para medicamentos existentes
    for (int i = 0; i < _medications.length; i++) {
      final medication = _medications[i];
      final controllers = _MedicationRowControllers();
      controllers.nameController.text = medication.name;
      controllers.dosageController.text = medication.dosage;
      controllers.frequencyController.text = medication.frequency;
      controllers.instructionsController.text = medication.instructions ?? '';
      _controllers.add(controllers);
    }

    // Siempre asegurar que hay al menos una fila de campos
    if (_controllers.isEmpty) {
      _controllers.add(_MedicationRowControllers());
    }
  }

  void _addNewMedicationRow() {
    setState(() {
      _controllers.add(_MedicationRowControllers());
    });
  }

  void _removeMedicationRow(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
        _updateMedications();
      });
    }
  }

  void _updateMedications() {
    final medications = <Medication>[];

    for (int i = 0; i < _controllers.length; i++) {
      final controller = _controllers[i];
      final name = controller.nameController.text.trim();
      final dosage = controller.dosageController.text.trim();
      final frequency = controller.frequencyController.text.trim();
      final instructions = controller.instructionsController.text.trim();

      // Solo agregar si al menos el nombre está lleno
      if (name.isNotEmpty) {
        medications.add(Medication(
          id: i < _medications.length ? _medications[i].id : null,
          name: name,
          dosage: dosage.isEmpty ? 'No especificada' : dosage,
          frequency: frequency.isEmpty ? 'No especificada' : frequency,
          instructions: instructions.isEmpty ? null : instructions,
        ));
      }
    }

    _medications = medications;
    widget.onMedicationsChanged(_medications);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista scrollable de filas de medicamentos
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(
                  _controllers.length,
                  (index) => _buildMedicationRow(index),
                ),
              ],
            ),
          ),
        ),

        // Botón para agregar nueva fila siempre al fondo
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: 350,
            child: OutlinedButton.icon(
              onPressed: _addNewMedicationRow,
              icon: const Icon(Icons.add, color: Colors.blue),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue),
              ),
              label: const Text('Agregar Medicamento', style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationRow(int index) {
    final controller = _controllers[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header de la fila
            Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medicamento ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_controllers.length > 1)
                  IconButton(
                    onPressed: () => _removeMedicationRow(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Eliminar medicamento',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Campos del medicamento
            Column(
              children: [
                // Fila 1: Nombre y Dosis
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildAutocompleteField(
                        controller: controller.nameController,
                        labelText: 'Nombre del medicamento *',
                        hintText: 'Ej: Paracetamol',
                        prefixIcon: Icons.medication,
                        suggestions: _commonMedications,
                        onChanged: (_) => _updateMedications(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildAutocompleteField(
                        controller: controller.dosageController,
                        labelText: 'Dosis *',
                        hintText: 'Ej: 500mg',
                        prefixIcon: Icons.straighten,
                        suggestions: _commonDosages,
                        onChanged: (_) => _updateMedications(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Fila 2: Frecuencia y Tiempo
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildAutocompleteField(
                        controller: controller.frequencyController,
                        labelText: 'Frecuencia *',
                        hintText: 'Ej: Cada 8 horas',
                        prefixIcon: Icons.schedule,
                        suggestions: _commonFrequencies,
                        onChanged: (_) => _updateMedications(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildAutocompleteField(
                        controller: controller.instructionsController,
                        labelText: 'Tiempo/Instrucciones',
                        hintText: 'Ej: Con alimentos',
                        prefixIcon: Icons.info_outline,
                        suggestions: _commonInstructions,
                        onChanged: (_) => _updateMedications(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompleteField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required List<String> suggestions,
    required Function(String) onChanged,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        final filteredOptions = suggestions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        }).toList();

        // Ordenar: coincidencias exactas primero, luego alfabéticamente
        filteredOptions.sort((a, b) {
          final aLower = a.toLowerCase();
          final bLower = b.toLowerCase();
          final queryLower = textEditingValue.text.toLowerCase();

          // Si uno empieza con la query y el otro no
          if (aLower.startsWith(queryLower) && !bLower.startsWith(queryLower)) {
            return -1;
          } else if (!aLower.startsWith(queryLower) && bLower.startsWith(queryLower)) {
            return 1;
          }

          // Si ambos empiezan con la query o ninguno, ordenar alfabéticamente
          return a.compareTo(b);
        });

        return filteredOptions.take(8); // Limitar a 8 sugerencias para no sobrecargar
      },
      onSelected: (String selection) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.text = selection;
          // Colocar el cursor al final del texto seleccionado
          controller.selection = TextSelection.collapsed(offset: selection.length);
          onChanged(selection);
        });
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onEditingComplete) {
        // Sincronizar el controller externo con el interno del Autocomplete solo si es necesario
        if (textEditingController.text != controller.text) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (textEditingController.text != controller.text) {
              textEditingController.text = controller.text;
              // Validar que la selección esté dentro de los límites del texto
              final textLength = controller.text.length;
              if (controller.selection.start <= textLength && controller.selection.end <= textLength) {
                textEditingController.selection = controller.selection;
              } else {
                // Si la selección está fuera de los límites, colocar el cursor al final
                textEditingController.selection = TextSelection.collapsed(offset: textLength);
              }
            }
          });
        }

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(prefixIcon),
          ),
          onChanged: (value) {
            // Usar addPostFrameCallback para evitar setState durante build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.text != value) {
                controller.text = value;
                // Validar que la selección esté dentro de los límites del nuevo texto
                final textLength = value.length;
                final currentSelection = textEditingController.selection;
                if (currentSelection.start <= textLength && currentSelection.end <= textLength) {
                  controller.selection = currentSelection;
                } else {
                  controller.selection = TextSelection.collapsed(offset: textLength);
                }
                onChanged(value);
              }
            });
          },
          onEditingComplete: onEditingComplete,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
                maxWidth: 300,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    leading: Icon(
                      Icons.history,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _MedicationRowControllers {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    instructionsController.dispose();
  }
}

