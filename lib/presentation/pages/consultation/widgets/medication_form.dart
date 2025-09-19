import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:doctor_app/data/models/medication.dart';
import 'package:doctor_app/presentation/widgets/autocomplete_field.dart';

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

  // Sugerencias comunes de medicamentos
  static const List<String> _commonMedications = [
    'Paracetamol',
    'Ibuprofeno',
    'Aspirina',
    'Amoxicilina',
    'Azitromicina',
    'Ciprofloxacino',
    'Omeprazol',
    'Ranitidina',
    'Loratadina',
    'Cetirizina',
    'Salbutamol',
    'Prednisolona',
    'Metformina',
    'Losartán',
    'Enalapril',
    'Atorvastatina',
    'Simvastatina',
    'Furosemida',
    'Hidroclorotiazida',
    'Captopril',
    'Amlodipino',
    'Metropolol',
    'Propranolol',
    'Warfarina',
    'Clopidogrel',
    'Insulina',
    'Glibenclamida',
    'Levotiroxina',
    'Diclofenaco',
    'Naproxeno',
    'Ketorolaco',
    'Tramadol',
    'Morfina',
    'Codeína',
    'Dexametasona',
    'Betametasona',
    'Hidrocortisona',
    'Fluticasona',
    'Budesonida',
    'Montelukast',
  ];

  static const List<String> _commonFrequencies = [
    'Cada 8 horas',
    'Cada 12 horas',
    'Cada 24 horas',
    '2 veces al día',
    '3 veces al día',
    '1 vez al día',
    'Cada 6 horas',
    'Cada 4 horas',
    'Cuando sea necesario',
    'En ayunas',
    'Después de las comidas',
    'Antes de dormir',
    'Al despertar',
  ];

  @override
  void initState() {
    super.initState();
    _medications = List.from(widget.initialMedications);
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onMedicationAdded: (medication) {
          setState(() {
            _medications.add(medication);
          });
          widget.onMedicationsChanged(_medications);
        },
      ),
    );
  }

  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        medication: _medications[index],
        onMedicationAdded: (medication) {
          setState(() {
            _medications[index] = medication;
          });
          widget.onMedicationsChanged(_medications);
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
    widget.onMedicationsChanged(_medications);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Lista de medicamentos
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Fixed height
            child: _medications.isEmpty
                ? _buildEmptyState()
                : _buildMedicationsList(),
          ),
            ],
          ),
        ),
        // FloatingActionButton para agregar medicamentos
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _addMedication,
            tooltip: 'Agregar medicamento',
            child: const Icon(Icons.add),
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
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay medicamentos recetados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona "Agregar" para recetar medicamentos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildMedicationsList() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la lista
          Row(
            children: [
              Text(
                'Medicamentos Recetados',
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
                  '${_medications.length}',
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

          // Lista de medicamentos
          SizedBox(
            height: 200, // Fixed height for list
            child: ListView.builder(
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final medication = _medications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.medication,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      medication.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Dosis: ${medication.dosage}'),
                        Text('Frecuencia: ${medication.frequency}'),
                        if (medication.instructions?.isNotEmpty == true)
                          Text('Instrucciones: ${medication.instructions}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editMedication(index),
                          tooltip: 'Editar medicamento',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[400],
                          ),
                          onPressed: () => _showDeleteDialog(index, medication.name),
                          tooltip: 'Eliminar medicamento',
                        ),
                      ],
                    ),
                    isThreeLine: medication.instructions?.isNotEmpty == true,
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

  Future<void> _showDeleteDialog(int index, String medicationName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Medicamento'),
        content: Text('¿Eliminar "$medicationName" de la receta?'),
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
      _removeMedication(index);
    }
  }
}

class _MedicationDialog extends StatefulWidget {
  final Medication? medication;
  final Function(Medication) onMedicationAdded;

  const _MedicationDialog({
    this.medication,
    required this.onMedicationAdded,
  });

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _frequencyController.text = widget.medication!.frequency;
      _instructionsController.text = widget.medication!.instructions ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          minWidth: MediaQuery.of(context).size.width > 500 ? 500 : MediaQuery.of(context).size.width * 0.9,
          minHeight: MediaQuery.of(context).size.height > 400 ? 400 : MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.medication != null ? 'Editar Medicamento' : 'Agregar Medicamento',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 32),

            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // Nombre del medicamento
              AutocompleteField(
                labelText: 'Nombre del medicamento *',
                prefixIcon: Icons.medication,
                suggestions: _MedicationFormState._commonMedications,
                onItemAdded: (name) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _nameController.text = name;
                  });
                },
                hintText: 'Ej: Paracetamol',
              ),
              const SizedBox(height: 24),

              // Dosis
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosis *',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 500mg, 1 tableta',
                ),
                validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Frecuencia
              AutocompleteField(
                labelText: 'Frecuencia *',
                prefixIcon: Icons.schedule,
                suggestions: _MedicationFormState._commonFrequencies,
                onItemAdded: (frequency) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _frequencyController.text = frequency;
                  });
                },
                hintText: 'Ej: Cada 8 horas',
              ),
              const SizedBox(height: 24),

              // Instrucciones
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instrucciones (opcional)',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Tomar con alimentos',
                ),
                maxLines: 3,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _saveMedication,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate() && _nameController.text.trim().isNotEmpty) {
      final medication = Medication(
        id: widget.medication?.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
      );

      widget.onMedicationAdded(medication);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}