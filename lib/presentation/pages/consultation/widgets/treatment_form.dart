import 'package:flutter/material.dart';
import 'package:doctor_app/presentation/widgets/autocomplete_field.dart';

class TreatmentForm extends StatefulWidget {
  final List<String> initialTreatments;
  final Function(List<String>) onTreatmentsChanged;

  const TreatmentForm({
    super.key,
    required this.initialTreatments,
    required this.onTreatmentsChanged,
  });

  @override
  State<TreatmentForm> createState() => _TreatmentFormState();
}

class _TreatmentFormState extends State<TreatmentForm> {
  late List<String> _treatments;

  // Sugerencias comunes de tratamientos médicos
  static const List<String> _commonTreatments = [
    'Reposo en cama',
    'Hidratación abundante',
    'Dieta blanda',
    'Aplicar calor local',
    'Aplicar frío local',
    'Ejercicios de fisioterapia',
    'Ejercicios respiratorios',
    'Cambio de posición frecuente',
    'Elevación de miembros',
    'Vendaje compresivo',
    'Inmovilización',
    'Movilización temprana',
    'Dieta hipocalórica',
    'Dieta hiposódica',
    'Dieta rica en fibra',
    'Dieta sin gluten',
    'Suspender tabaquismo',
    'Suspender alcohol',
    'Control de glucemia',
    'Control de presión arterial',
    'Control de peso',
    'Seguimiento médico',
    'Educación al paciente',
    'Terapia psicológica',
    'Terapia ocupacional',
    'Oxigenoterapia',
    'Nebulizaciones',
    'Lavado nasal',
    'Gárgaras con agua salada',
    'Masajes terapéuticos',
    'Acupuntura',
    'Yoga terapéutico',
    'Meditación',
    'Técnicas de relajación',
    'Terapia de grupo',
    'Rehabilitación cardíaca',
    'Rehabilitación pulmonar',
    'Rehabilitación neurológica',
    'Cuidados de heridas',
    'Curación diaria',
    'Baños medicados',
    'Fototerapia',
    'Termoterapia',
    'Crioterapia',
    'Electroterapia',
    'Ultrasonido terapéutico',
    'Láser terapéutico',
    'Magnetoterapia',
    'Hidroterapia',
  ];

  @override
  void initState() {
    super.initState();
    _treatments = List.from(widget.initialTreatments);
  }

  void _addTreatment(String treatment) {
    if (treatment.isNotEmpty && !_treatments.contains(treatment)) {
      setState(() {
        _treatments.add(treatment);
      });
      widget.onTreatmentsChanged(_treatments);
    }
  }

  void _removeTreatment(int index) {
    setState(() {
      _treatments.removeAt(index);
    });
    widget.onTreatmentsChanged(_treatments);
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
                Icons.healing,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan de Tratamiento',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Define el plan de tratamiento y cuidados para el paciente',
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
            labelText: 'Agregar tratamiento',
            prefixIcon: Icons.add_circle_outline,
            suggestions: _commonTreatments,
            onItemAdded: _addTreatment,
            hintText: 'Ej: Reposo en cama, hidratación...',
            helperText: 'Escribe y presiona Enter o selecciona de las sugerencias',
          ),
          const SizedBox(height: 24),

          // Lista de tratamientos agregados
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Fixed height
            child: _treatments.isEmpty
                ? _buildEmptyState()
                : _buildTreatmentsList(),
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
              Icons.healing_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay tratamientos definidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega los tratamientos y cuidados que debe seguir el paciente',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildTreatmentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Header de la lista
          Row(
            children: [
              Text(
                'Plan de Tratamiento',
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
                  '${_treatments.length}',
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

          // Lista de tratamientos
          SizedBox(
            height: 200, // Fixed height for list
            child: ListView.builder(
              itemCount: _treatments.length,
              itemBuilder: (context, index) {
                final treatment = _treatments[index];
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
                      treatment,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                      ),
                      onPressed: () => _showDeleteDialog(index, treatment),
                      tooltip: 'Eliminar tratamiento',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

  Future<void> _showDeleteDialog(int index, String treatment) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tratamiento'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: '¿Estás seguro de que deseas eliminar '),
              TextSpan(
                text: '"$treatment"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' del plan de tratamiento?'),
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
      _removeTreatment(index);
    }
  }
}