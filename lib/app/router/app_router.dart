import 'package:go_router/go_router.dart';
import 'package:doctor_app/presentation/pages/patients/patients_list_page.dart';
import 'package:doctor_app/presentation/pages/patients/add_patient_page.dart';
import 'package:doctor_app/presentation/pages/patients/patient_consultations_page.dart';
import 'package:doctor_app/presentation/pages/consultation/consultation_page.dart';
import 'package:doctor_app/presentation/pages/statistics/statistics_page.dart';
import 'package:doctor_app/presentation/pages/settings/settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/patients',
  routes: [
    GoRoute(
      path: '/patients',
      name: 'patients',
      builder: (context, state) => const PatientsListPage(),
    ),
    GoRoute(
      path: '/patients/add',
      name: 'add-patient',
      builder: (context, state) => const AddPatientPage(),
    ),
    GoRoute(
      path: '/patients/:id',
      name: 'patient-consultations',
      builder: (context, state) {
        final patientId = int.parse(state.pathParameters['id']!);
        return PatientConsultationsPage(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/patients/:id/consultation',
      name: 'consultation',
      builder: (context, state) {
        final patientId = int.parse(state.pathParameters['id']!);
        return ConsultationPage(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/statistics',
      name: 'statistics',
      builder: (context, state) => const StatisticsPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);