import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/repositories/statistics_repository.dart';

// Provider for the repository
final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository();
});

// Statistics data models
class StatisticsData {
  final int totalPatients;
  final int totalConsultations;
  final double totalRevenue;
  final Map<String, int> consultationsByDay;
  final Map<String, double> revenueByDay;
  final Map<String, int> topSymptoms;
  final Map<String, int> topMedications;
  final Map<String, int> topDiagnoses;
  final Map<String, int> frequentPatients;
  final Map<String, List<Map<String, dynamic>>> recurringPatientsWeightEvolution;
  final Map<String, Map<String, int>> symptomsVsDiagnoses;
  final Map<int, Map<String, int>> monthlyDiagnoses;
  final Map<String, int> ageDemographics;

  StatisticsData({
    required this.totalPatients,
    required this.totalConsultations,
    required this.totalRevenue,
    required this.consultationsByDay,
    required this.revenueByDay,
    required this.topSymptoms,
    required this.topMedications,
    required this.topDiagnoses,
    required this.frequentPatients,
    required this.recurringPatientsWeightEvolution,
    required this.symptomsVsDiagnoses,
    required this.monthlyDiagnoses,
    required this.ageDemographics,
  });
}

// Statistics provider
class StatisticsNotifier extends StateNotifier<AsyncValue<StatisticsData>> {
  final StatisticsRepository _repository;

  StatisticsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      state = const AsyncValue.loading();

      final startDate = DateTime(2000);
      final endDate = DateTime.now();

      // Load statistics sequentially to avoid database locks
      // Add delays between queries to prevent database locks
      final totalPatients = await _repository.getTotalPatients();
      await Future.delayed(const Duration(milliseconds: 50));

      final totalConsultations = await _repository.getConsultationsInDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final totalRevenue = await _repository.getTotalRevenueInDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final consultationsByDay = await _repository.getConsultationsByDay(
        startDate: startDate,
        endDate: endDate,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final revenueByDay = await _repository.getRevenueByDay(
        startDate: startDate,
        endDate: endDate,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final topSymptoms = await _repository.getMostFrequentSymptomsInDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: 10,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final topMedications = await _repository.getMostPrescribedMedicationsInDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: 10,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final topDiagnoses = await _repository.getMostCommonDiagnosesInDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: 10,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final frequentPatients = await _repository.getMostFrequentPatientsInDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: 10,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final recurringPatientsWeightEvolution = await _repository.getRecurringPatientsWeightEvolution(
        startDate: startDate,
        endDate: endDate,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final symptomsVsDiagnoses = await _repository.getSymptomsVsDiagnosesCorrelation(
        startDate: startDate,
        endDate: endDate,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final monthlyDiagnoses = await _repository.getDiagnosesByMonth(
        startDate: startDate,
        endDate: endDate,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      final ageDemographics = await _repository.getPatientAgeDemographics();

      final statisticsData = StatisticsData(
        totalPatients: totalPatients,
        totalConsultations: totalConsultations,
        totalRevenue: totalRevenue,
        consultationsByDay: consultationsByDay,
        revenueByDay: revenueByDay,
        topSymptoms: topSymptoms,
        topMedications: topMedications,
        topDiagnoses: topDiagnoses,
        frequentPatients: frequentPatients,
        recurringPatientsWeightEvolution: recurringPatientsWeightEvolution,
        symptomsVsDiagnoses: symptomsVsDiagnoses,
        monthlyDiagnoses: monthlyDiagnoses,
        ageDemographics: ageDemographics,
      );

      state = AsyncValue.data(statisticsData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    loadStatistics();
  }
}

// Statistics provider - autoDispose to prevent issues when not in use
final statisticsProvider = StateNotifierProvider.autoDispose<StatisticsNotifier, AsyncValue<StatisticsData>>((ref) {
  final repository = ref.watch(statisticsRepositoryProvider);

  // Keep alive temporarily during seeding operations to prevent dispose errors
  final link = ref.keepAlive();

  // Auto-dispose after 30 seconds of inactivity to free up memory
  Timer? timer;
  ref.onCancel(() {
    timer = Timer(const Duration(seconds: 30), () {
      link.close();
    });
  });

  ref.onResume(() {
    timer?.cancel();
  });

  return StatisticsNotifier(repository);
});

// Alias for the statistics provider (since it already handles date range changes)
final statisticsWithDateRangeProvider = statisticsProvider;