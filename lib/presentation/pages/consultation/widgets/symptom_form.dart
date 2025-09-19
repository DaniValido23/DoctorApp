import 'package:flutter/material.dart';
import 'package:doctor_app/presentation/widgets/autocomplete_field.dart';

class SymptomForm extends StatefulWidget {
  final List<String> initialSymptoms;
  final Function(List<String>) onSymptomsChanged;

  const SymptomForm({
    super.key,
    required this.initialSymptoms,
    required this.onSymptomsChanged,
  });

  @override
  State<SymptomForm> createState() => _SymptomFormState();
}

class _SymptomFormState extends State<SymptomForm> {
  late List<String> _symptoms;

  // Sugerencias comunes de síntomas médicos
  static const List<String> _commonSymptoms = [
    'Dolor de cabeza',
    'Fiebre',
    'Tos',
    'Dolor de garganta',
    'Fatiga',
    'Náuseas',
    'Vómitos',
    'Diarrea',
    'Estreñimiento',
    'Dolor abdominal',
    'Dolor de pecho',
    'Dificultad para respirar',
    'Mareos',
    'Dolor de espalda',
    'Dolor articular',
    'Dolor muscular',
    'Erupciones cutáneas',
    'Picazón',
    'Pérdida de apetito',
    'Insomnio',
    'Sudoración excesiva',
    'Escalofríos',
    'Congestión nasal',
    'Secreción nasal',
    'Estornudos',
    'Ojos llorosos',
    'Visión borrosa',
    'Pérdida de audición',
    'Zumbido en los oídos',
    'Palpitaciones',
    'Hinchazón',
    'Moretones',
    'Sangrado',
    'Entumecimiento',
    'Hormigueo',
    'Debilidad',
    'Confusión',
    'Pérdida de memoria',
    'Cambios de humor',
    'Ansiedad',
    'Depresión',
    'Pérdida de peso',
    'Aumento de peso',
    'Sed excesiva',
    'Micción frecuente',
    'Dolor al orinar',
    'Dolor menstrual',
    'Sangrado menstrual irregular',
  ];

  @override
  void initState() {
    super.initState();
    _symptoms = List.from(widget.initialSymptoms);
  }

  void _addSymptom(String symptom) {
    if (symptom.isNotEmpty && !_symptoms.contains(symptom)) {
      setState(() {
        _symptoms.add(symptom);
      });
      widget.onSymptomsChanged(_symptoms);
    }
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
    });
    widget.onSymptomsChanged(_symptoms);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.sick,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Síntomas del Paciente',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Registra todos los síntomas que presenta el paciente',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Autocomplete field
          AutocompleteField(
            labelText: 'Agregar síntoma',
            prefixIcon: Icons.add_circle_outline,
            suggestions: _commonSymptoms,
            onItemAdded: _addSymptom,
            hintText: 'Ej: Dolor de cabeza, fiebre...',
            helperText: 'Escribe y presiona Enter o selecciona de las sugerencias',
          ),
          const SizedBox(height: 24),

          // Lista de síntomas agregados
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: _symptoms.isEmpty
                ? _buildEmptyState()
                : _buildSymptomsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sick_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay síntomas registrados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega los síntomas del paciente usando el campo de arriba',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la lista
        Row(
          children: [
            Text(
              'Síntomas Registrados',
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
                '${_symptoms.length}',
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

        // Lista de síntomas
        Expanded(
          child: ListView.builder(
            itemCount: _symptoms.length,
            itemBuilder: (context, index) {
              final symptom = _symptoms[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    radius: 16,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    symptom,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                    ),
                    onPressed: () => _showDeleteDialog(index, symptom),
                    tooltip: 'Eliminar síntoma',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(int index, String symptom) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Síntoma'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: '¿Estás seguro de que deseas eliminar '),
              TextSpan(
                text: '"$symptom"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' de la lista de síntomas?'),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _removeSymptom(index);
    }
  }
}