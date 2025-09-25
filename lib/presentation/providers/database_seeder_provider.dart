import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/database/database_seeder.dart';
import 'package:doctor_app/presentation/providers/providers.dart';
import 'package:doctor_app/core/utils/utils.dart';

// Seeder service provider
final databaseSeederProvider = Provider<DatabaseSeeder>((ref) {
  return DatabaseSeeder();
});

// Seeding state
enum SeedingState {
  idle,
  seeding,
  clearing,
  error,
}

class SeedingStatus {
  final SeedingState state;
  final bool hasSeedData;
  final String? errorMessage;

  SeedingStatus({
    required this.state,
    required this.hasSeedData,
    this.errorMessage,
  });

  SeedingStatus copyWith({
    SeedingState? state,
    bool? hasSeedData,
    String? errorMessage,
  }) {
    return SeedingStatus(
      state: state ?? this.state,
      hasSeedData: hasSeedData ?? this.hasSeedData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Seeding notifier
class SeedingNotifier extends StateNotifier<SeedingStatus> {
  final DatabaseSeeder _seeder;
  final Ref _ref;

  SeedingNotifier(this._seeder, this._ref) : super(SeedingStatus(
    state: SeedingState.idle,
    hasSeedData: false,
  )) {
    _checkSeedData();
  }


  Future<void> _checkSeedData() async {
    try {
      final hasSeedData = await _seeder.hasSeedData();
      state = state.copyWith(hasSeedData: hasSeedData);
    } catch (e) {
      state = state.copyWith(
        state: SeedingState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleSeedData() async {
    if (state.state == SeedingState.seeding || state.state == SeedingState.clearing) {
      return; // Ya está procesando
    }

    try {
      if (state.hasSeedData) {
        // Limpiar datos
        state = state.copyWith(state: SeedingState.clearing);
        await _seeder.clearSeedData();
        state = state.copyWith(
          state: SeedingState.idle,
          hasSeedData: false,
        );

        // Invalidate providers to refresh data
        _invalidateDataProviders();
      } else {
        // Poblar datos
        state = state.copyWith(state: SeedingState.seeding);
        await _seeder.seedDatabase();
        state = state.copyWith(
          state: SeedingState.idle,
          hasSeedData: true,
        );

        // Invalidate providers to refresh data
        _invalidateDataProviders();
      }
    } catch (e) {
      state = state.copyWith(
        state: SeedingState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> seedDatabase() async {
    if (state.state == SeedingState.seeding || state.state == SeedingState.clearing) {
      return; // Ya está procesando
    }

    try {
      state = state.copyWith(state: SeedingState.seeding);
      await _seeder.seedDatabase();
      state = state.copyWith(
        state: SeedingState.idle,
        hasSeedData: true,
      );

      // Invalidate providers to refresh data
      _invalidateDataProviders();
    } catch (e) {
      state = state.copyWith(
        state: SeedingState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> clearSeedData() async {
    if (state.state == SeedingState.seeding || state.state == SeedingState.clearing) {
      return; // Ya está procesando
    }

    try {
      appLogger.d('DEBUG: Iniciando eliminación de datos de prueba');
      state = state.copyWith(state: SeedingState.clearing);
      await _seeder.clearSeedData();

      // Verificar que realmente se eliminaron los datos
      final hasSeedDataAfterClear = await _seeder.hasSeedData();
      appLogger.i('DEBUG: Datos eliminados exitosamente. Tiene datos de prueba: $hasSeedDataAfterClear');

      state = state.copyWith(
        state: SeedingState.idle,
        hasSeedData: hasSeedDataAfterClear,
      );

      // Invalidate providers to refresh data
      _invalidateDataProviders();
    } catch (e) {
      appLogger.e('DEBUG: Error al eliminar datos', error: e);
      state = state.copyWith(
        state: SeedingState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      state: SeedingState.idle,
      errorMessage: null,
    );
  }

  void _invalidateDataProviders() {
    // Invalidate patient provider to refresh patient list
    try {
      _ref.invalidate(patientProvider);
    } catch (e) {
      // Provider may have been disposed, ignore
    }

    // Invalidate consultation provider to refresh consultation data
    try {
      _ref.invalidate(consultationProvider);
    } catch (e) {
      // Provider may have been disposed, ignore
    }

    // Safely invalidate statistics provider
    // Use a delayed invalidation to ensure it happens after the current operation
    Future.microtask(() {
      try {
        // Try to check if the provider exists before invalidating
        if (_ref.exists(statisticsProvider)) {
          _ref.invalidate(statisticsProvider);
        }
      } catch (e) {
        // Statistics provider was disposed or doesn't exist, that's fine
        // It will be recreated when needed with fresh data
      }
    });
  }
}

// Seeding provider
final seedingProvider = StateNotifierProvider<SeedingNotifier, SeedingStatus>((ref) {
  final seeder = ref.watch(databaseSeederProvider);
  return SeedingNotifier(seeder, ref);
});