import 'package:flutter/material.dart';

class VitalSignsSection extends StatelessWidget {
  final TextEditingController temperatureController;
  final TextEditingController systolicPressureController;
  final TextEditingController diastolicPressureController;
  final TextEditingController oxygenSaturationController;
  final TextEditingController weightController;
  final TextEditingController heightController;

  const VitalSignsSection({
    super.key,
    required this.temperatureController,
    required this.systolicPressureController,
    required this.diastolicPressureController,
    required this.oxygenSaturationController,
    required this.weightController,
    required this.heightController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.monitor_heart,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signos Vitales',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Todos los campos son opcionales',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Vital signs grid
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine grid layout based on available space
                final isWideScreen = constraints.maxWidth > 600;
                return isWideScreen
                    ? _buildWideLayout()
                    : _buildNarrowLayout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row: Temperature, Blood Pressure
        Row(
          children: [
            Expanded(child: _buildTemperatureField()),
            const SizedBox(width: 16),
            Expanded(child: _buildBloodPressureField()),
          ],
        ),
        const SizedBox(height: 16),

        // Second row: Oxygen Saturation, Weight, Height
        Row(
          children: [
            Expanded(child: _buildOxygenSaturationField()),
            const SizedBox(width: 16),
            Expanded(child: _buildWeightField()),
            const SizedBox(width: 16),
            Expanded(child: _buildHeightField()),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTemperatureField(),
        const SizedBox(height: 16),
        _buildBloodPressureField(),
        const SizedBox(height: 16),
        _buildOxygenSaturationField(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildWeightField()),
            const SizedBox(width: 16),
            Expanded(child: _buildHeightField()),
          ],
        ),
      ],
    );
  }

  Widget _buildTemperatureField() {
    return TextFormField(
      controller: temperatureController,
      decoration: InputDecoration(
        labelText: 'Temperatura Corporal',
        hintText: '36.5',
        suffixText: '°C',
        prefixIcon: Icon(Icons.thermostat, color: Colors.orange[700]),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.orange.withValues(alpha: 0.05),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value?.isEmpty == true) return null; // Optional field
        final temp = double.tryParse(value!);
        if (temp == null) return 'Temperatura inválida';
        if (temp < 30.0 || temp > 45.0) return 'Rango: 30°C - 45°C';
        return null;
      },
    );
  }

  Widget _buildBloodPressureField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: systolicPressureController,
            decoration: InputDecoration(
              labelText: 'Presión arterial sistólica',
              hintText: '120',
              suffixText: 'mmHg',
              prefixIcon: Icon(Icons.favorite, color: Colors.red[700]),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.red.withValues(alpha: 0.05),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty == true) return null; // Optional
              final systolic = int.tryParse(value!);
              if (systolic == null) return 'Inválido';
              if (systolic < 60 || systolic > 250) return '60-250 mmHg';
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '/',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: diastolicPressureController,
            decoration: InputDecoration(
              labelText: 'Presión Arterial diastólica',
              hintText: '80',
              suffixText: 'mmHg',
              prefixIcon: Icon(Icons.favorite, color: Colors.blue[700]),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.red.withValues(alpha: 0.05),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty == true) return null; // Optional
              final diastolic = int.tryParse(value!);
              if (diastolic == null) return 'Inválido';
              if (diastolic < 40 || diastolic > 150) return '40-150 mmHg';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOxygenSaturationField() {
    return TextFormField(
      controller: oxygenSaturationController,
      decoration: InputDecoration(
        labelText: 'Saturación de Oxígeno',
        hintText: '98',
        suffixText: '%',
        prefixIcon: Icon(Icons.air, color: Colors.blue[700]),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.blue.withValues(alpha: 0.05),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value?.isEmpty == true) return null; // Optional field
        final oxygen = double.tryParse(value!);
        if (oxygen == null) return 'Saturación inválida';
        if (oxygen < 70.0 || oxygen > 100.0) return 'Rango: 70% - 100%';
        return null;
      },
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: weightController,
      decoration: InputDecoration(
        labelText: 'Peso',
        hintText: '70.5',
        suffixText: 'kg',
        prefixIcon: Icon(Icons.fitness_center, color: Colors.green[700]),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.green.withValues(alpha: 0.05),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value?.isEmpty == true) return null; // Optional field
        final weight = double.tryParse(value!);
        if (weight == null) return 'Peso inválido';
        if (weight <= 0 || weight > 500) return 'Rango: 0.1kg - 500kg';
        return null;
      },
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: heightController,
      decoration: InputDecoration(
        labelText: 'Altura',
        hintText: '170',
        suffixText: 'cm',
        prefixIcon: Icon(Icons.height, color: Colors.purple[700]),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.purple.withValues(alpha: 0.05),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value?.isEmpty == true) return null; // Optional field
        final height = double.tryParse(value!);
        if (height == null) return 'Altura inválida';
        if (height <= 20 || height > 250) return 'Rango: 20cm - 250cm';
        return null;
      },
    );
  }
}