import 'package:flutter/material.dart';
import 'package:doctor_app/presentation/widgets/autocomplete_field.dart';

class DiagnosisForm extends StatefulWidget {
  final List<String> initialDiagnoses;
  final Function(List<String>) onDiagnosesChanged;

  const DiagnosisForm({
    super.key,
    required this.initialDiagnoses,
    required this.onDiagnosesChanged,
  });

  @override
  State<DiagnosisForm> createState() => _DiagnosisFormState();
}

class _DiagnosisFormState extends State<DiagnosisForm> {
  late List<String> _diagnoses;

  // Sugerencias comunes de diagnósticos médicos
  static const List<String> _commonDiagnoses = [
    'Infección respiratoria aguda',
    'Gastroenteritis aguda',
    'Hipertensión arterial',
    'Diabetes mellitus tipo 2',
    'Obesidad',
    'Anemia ferropénica',
    'Cefalea tensional',
    'Lumbalgia',
    'Artritis',
    'Dermatitis',
    'Rinitis alérgica',
    'Asma bronquial',
    'Bronquitis aguda',
    'Neumonía',
    'Sinusitis',
    'Faringitis',
    'Amigdalitis',
    'Otitis media',
    'Conjuntivitis',
    'Cistitis',
    'Gastritis',
    'Reflujo gastroesofágico',
    'Síndrome de colon irritable',
    'Estreñimiento',
    'Hemorroides',
    'Migraña',
    'Vértigo',
    'Insomnio',
    'Ansiedad',
    'Depresión',
    'Fibromialgia',
    'Tendinitis',
    'Bursitis',
    'Esguince',
    'Contusión',
    'Herida superficial',
    'Quemadura de primer grado',
    'Eczema',
    'Psoriasis',
    'Acné',
    'Rosácea',
    'Urticaria',
    'Pie de atleta',
    'Candidiasis',
    'Herpes simple',
    'Varicela',
    'Gripe',
    'Resfriado común',
    'COVID-19',
    'Dengue',
    'Zika',
    'Chikungunya',
    'Hipotiroidismo',
    'Hipertiroidismo',
    'Osteoporosis',
    'Artosis',
    'Gota',
    'Várices',
    'Síndrome metabólico',
    'Dislipidemia',
    'Arritmia cardíaca',
    'Enfermedad renal crónica',
    'Hepatitis',
    'Cirrosis',
    'Cálculos biliares',
    'Apendicitis',
    'Hernia inguinal',
    'Prostatitis',
    'Infección urinaria',
  ];

  @override
  void initState() {
    super.initState();
    _diagnoses = List.from(widget.initialDiagnoses);
  }

  void _addDiagnosis(String diagnosis) {
    if (diagnosis.isNotEmpty && !_diagnoses.contains(diagnosis)) {
      setState(() {
        _diagnoses.add(diagnosis);
      });
      widget.onDiagnosesChanged(_diagnoses);
    }
  }

  void _removeDiagnosis(int index) {
    setState(() {
      _diagnoses.removeAt(index);
    });
    widget.onDiagnosesChanged(_diagnoses);
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
                Icons.medical_services,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnósticos Médicos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Establece los diagnósticos basados en la evaluación clínica',
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
            labelText: 'Agregar diagnóstico',
            prefixIcon: Icons.add_circle_outline,
            suggestions: _commonDiagnoses,
            onItemAdded: _addDiagnosis,
            hintText: 'Ej: Hipertensión arterial, diabetes...',
            helperText: 'Escribe y presiona Enter o selecciona de las sugerencias',
          ),
          const SizedBox(height: 24),

          // Lista de diagnósticos agregados
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Fixed height
            child: _diagnoses.isEmpty
                ? _buildEmptyState()
                : _buildDiagnosesList(),
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
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay diagnósticos registrados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega los diagnósticos basados en la evaluación del paciente',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildDiagnosesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Header de la lista
          Row(
            children: [
              Text(
                'Diagnósticos Establecidos',
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
                  '${_diagnoses.length}',
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

          // Lista de diagnósticos
          SizedBox(
            height: 200, // Fixed height for list
            child: ListView.builder(
              itemCount: _diagnoses.length,
              itemBuilder: (context, index) {
                final diagnosis = _diagnoses[index];
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
                      diagnosis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                      ),
                      onPressed: () => _showDeleteDialog(index, diagnosis),
                      tooltip: 'Eliminar diagnóstico',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

  Future<void> _showDeleteDialog(int index, String diagnosis) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Diagnóstico'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: '¿Estás seguro de que deseas eliminar '),
              TextSpan(
                text: '"$diagnosis"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' de los diagnósticos?'),
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
      _removeDiagnosis(index);
    }
  }
}