import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/app/router/app_router.dart';
import 'package:doctor_app/app/theme/app_theme.dart';
import 'package:doctor_app/app/theme/theme_provider.dart';

class DoctorApp extends ConsumerWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Consultorio Médico',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}