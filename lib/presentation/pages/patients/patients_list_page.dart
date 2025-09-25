import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_app/core/widgets/custom_drawer.dart';
import 'package:doctor_app/presentation/providers/patient_provider.dart';
import 'package:doctor_app/presentation/pages/patients/widgets/patient_card.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/core/utils/responsive_utils.dart';

class PatientsListPage extends ConsumerStatefulWidget {
  const PatientsListPage({super.key});

  @override
  ConsumerState<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends ConsumerState<PatientsListPage> {
  final _searchController = TextEditingController();
  List<Patient> _filteredPatients = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar pacientes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _filterPatients,
              )
            : const Text('Pacientes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: patientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(error),
        data: (patients) => _buildPatientsList(patients),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_patient_fab",
        onPressed: () => context.go('/patients/add'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Paciente'),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar pacientes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(patientProvider.notifier).loadPatients(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList(List<Patient> patients) {
    // Sort patients alphabetically by name
    final sortedPatients = List<Patient>.from(patients)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final displayPatients = _isSearching && _searchController.text.isNotEmpty
        ? _filteredPatients
        : sortedPatients;

    if (patients.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching && _searchController.text.isNotEmpty && _filteredPatients.isEmpty) {
      return _buildNoResultsFound();
    }

    return Column(
      children: [
        // Stats bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            _isSearching && _searchController.text.isNotEmpty
                ? 'Encontrados: ${displayPatients.length} de ${patients.length} pacientes'
                : 'Total: ${patients.length} paciente${patients.length != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Patients list
        Expanded(
          child: ResponsiveLayout(
            mobile: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: displayPatients.length,
              itemBuilder: (context, index) {
                final patient = displayPatients[index];
                return PatientCard(
                  patient: patient,
                  onTap: () => context.go('/patients/${patient.id}'),
                );
              },
            ),
            desktop: ResponsiveContainer(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.getGridColumns(context, maxColumns: 4),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: displayPatients.length,
                itemBuilder: (context, index) {
                  final patient = displayPatients[index];
                  return PatientCard(
                    patient: patient,
                    onTap: () => context.go('/patients/${patient.id}'),
                    isGridLayout: true,
                  );
                },
              ),
            ),
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
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pacientes registrados',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando tu primer paciente',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          // FilledButton.icon(
          //   onPressed: () => context.go('/patients/add'),
          //   icon: const Icon(Icons.add),
          //   label: const Text('Agregar Paciente'),
          // ),
        ],
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              _filterPatients('');
            },
            child: const Text('Limpiar búsqueda'),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredPatients.clear();
      }
    });
  }

  void _filterPatients(String query) {
    final patientsAsync = ref.read(patientProvider);
    patientsAsync.whenData((patients) {
      setState(() {
        if (query.isEmpty) {
          _filteredPatients = [];
        } else {
          _filteredPatients = patients.where((patient) {
            return patient.name.toLowerCase().contains(query.toLowerCase()) ||
                patient.phone.contains(query) ||
                (patient.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
          }).toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}