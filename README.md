# Proyecto App Consultorio Médico - Flutter

## 📋 Resumen del Proyecto

**Plataformas**: Android y Windows  
**Framework**: Flutter  
**Base de datos**: SQLite (local)  
**Arquitectura**: Riverpod + Clean Architecture

---
🎯 Contexto del Proyecto
App médica para consultorios en Flutter (Android/Windows) con gestión de pacientes, consultas médicas, generación de recetas PDF y estadísticas.
🏗️ Arquitectura y Dependencias
Stack Tecnológico

Framework: Flutter 3.x
Estado: Riverpod + riverpod_annotation
Navegación: go_router
Base de datos: SQLite (sqflite)
Serialización: freezed + json_annotation
PDFs: pdf + printing
Gráficos: fl_chart
Persistencia: shared_preferences

Arquitectura
Clean Architecture + Riverpod
├── Data Layer (repositories, database, models)
├── Domain Layer (entities, use cases)
└── Presentation Layer (pages, widgets, providers)
📋 Funcionalidades Principales
1. Gestión de Pacientes

Lista de pacientes con búsqueda
Formulario de registro: nombre, edad, fecha nacimiento, teléfono, email, sexo
Cards con información básica

2. Sistema de Consultas

Formulario complejo con múltiples secciones:

Síntomas (lista dinámica con autocomplete)
Medicamentos (con frecuencia específica)
Tratamientos (lista dinámica)
Diagnósticos (lista dinámica)
Archivos adjuntos (PDF, PNG, JPG)
Observaciones, peso, precio


Autocomplete inteligente basado en historial
Previsualización de archivos

3. Generación de PDFs

Receta médica tamaño carta
Incluye: datos paciente + consulta (excepto archivos y costo)
Logo personalizable del doctor
Preview antes de imprimir

4. Estadísticas con Gráficos

Pacientes atendidos por día
Síntomas más frecuentes
Medicamentos más recetados
Diagnósticos comunes
Ingresos generados

5. Configuraciones

Datos del doctor (nombre, especialidad, licenciatura, etc.)
Logo personalizable
Tema oscuro/claro
Información de contacto y ubicación



## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       ├── app_theme.dart
│       └── theme_provider.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── database_constants.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── file_utils.dart
│   │   └── pdf_generator.dart
│   └── widgets/
│       ├── custom_app_bar.dart
│       ├── custom_drawer.dart
│       ├── loading_widget.dart
│       └── error_widget.dart
├── data/
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── tables/
│   │       ├── patients_table.dart
│   │       ├── consultations_table.dart
│   │       ├── medications_table.dart
│   │       ├── symptoms_table.dart
│   │       ├── treatments_table.dart
│   │       └── diagnoses_table.dart
│   ├── models/
│   │   ├── patient.dart
│   │   ├── consultation.dart
│   │   ├── medication.dart
│   │   ├── symptom.dart
│   │   ├── treatment.dart
│   │   ├── diagnosis.dart
│   │   ├── attachment.dart
│   │   └── doctor_settings.dart
│   └── repositories/
│       ├── patient_repository.dart
│       ├── consultation_repository.dart
│       ├── medication_repository.dart
│       ├── settings_repository.dart
│       └── statistics_repository.dart
├── presentation/
│   ├── providers/
│   │   ├── patient_provider.dart
│   │   ├── consultation_provider.dart
│   │   ├── settings_provider.dart
│   │   └── statistics_provider.dart
│   ├── pages/
│   │   ├── patients/
│   │   │   ├── patients_list_page.dart
│   │   │   ├── add_patient_page.dart
│   │   │   └── widgets/
│   │   │       └── patient_card.dart
│   │   ├── consultation/
│   │   │   ├── consultation_page.dart
│   │   │   ├── pdf_preview_page.dart
│   │   │   └── widgets/
│   │   │       ├── medication_form.dart
│   │   │       ├── symptom_form.dart
│   │   │       ├── treatment_form.dart
│   │   │       ├── diagnosis_form.dart
│   │   │       └── attachment_widget.dart
│   │   ├── statistics/
│   │   │   ├── statistics_page.dart
│   │   │   └── widgets/
│   │   │       ├── daily_patients_chart.dart
│   │   │       ├── symptoms_chart.dart
│   │   │       ├── medications_chart.dart
│   │   │       └── revenue_chart.dart
│   │   └── settings/
│   │       ├── settings_page.dart
│   │       └── widgets/
│   │           └── doctor_info_form.dart
│   └── widgets/
│       ├── autocomplete_field.dart
│       ├── file_picker_widget.dart
│       └── prescription_preview.dart
└── services/
    ├── file_service.dart
    ├── pdf_service.dart
    └── backup_service.dart
```

---

## 📱 Pantallas Principales

### 1. Lista de Pacientes

- **Ruta**: `/patients`
- **Componentes**: Lista scrolleable, FAB, drawer
- **Funciones**: Mostrar pacientes, búsqueda, navegación

### 2. Estadísticas

- **Ruta**: `/statistics`
- **Componentes**: Gráficos con fl_chart
- **Funciones**: Visualización de datos, filtros por fecha

### 3. Configuraciones

- **Ruta**: `/settings`
- **Componentes**: Formularios, switches, file picker
- **Funciones**: Configuración del doctor, tema, backup

### Pantallas Secundarias

#### Agregar Paciente

- **Ruta**: `/patients/add`
- **Formulario**: Nombre, edad, fecha nacimiento, teléfono, email, sexo

#### Consulta

- **Ruta**: `/patients/:id/consultation`
- **Componentes**: Formularios múltiples, autocomplete, file picker
- **Funciones**: Registro consulta, generación PDF, previsualización

---

## 🗄️ Modelos de Datos

### Patient

```dart
@freezed
class Patient with _$Patient {
  factory Patient({
    int? id,
    required String name,
    required int age,
    required DateTime birthDate,
    required String phone,
    String? email,
    required String gender,
    required DateTime createdAt,
  }) = _Patient;
}
```

### Consultation

```dart
@freezed
class Consultation with _$Consultation {
  factory Consultation({
    int? id,
    required int patientId,
    required DateTime date,
    required List<String> symptoms,
    required List<Medication> medications,
    required List<String> treatments,
    required List<String> diagnoses,
    required double weight,
    String? observations,
    required List<Attachment> attachments,
    required double price,
  }) = _Consultation;
}
```

---

## 📋 TODO List Completa

### Fase 1: Configuración Base (Semana 1) ✅

- [x] Configurar proyecto Flutter con dependencias
- [x] Implementar go_router con rutas básicas
- [x] Configurar Riverpod y providers base
- [x] Crear modelos con Freezed y JSON serialization
- [x] Implementar tema claro/oscuro básico
- [x] Crear drawer de navegación

### Fase 2: Base de Datos (Semana 1-2)

- [ ] Configurar SQLite con sqflite
- [ ] Crear tablas de base de datos
- [ ] Implementar DatabaseHelper
- [ ] Crear repositorios base
- [ ] Implementar CRUD para pacientes
- [ ] Testear persistencia de datos

### Fase 3: Gestión de Pacientes (Semana 2-3)

- [ ] Crear página lista de pacientes
- [ ] Implementar PatientCard widget
- [ ] Crear formulario agregar paciente
- [ ] Implementar validación de formularios
- [ ] Agregar funcionalidad de búsqueda
- [ ] Conectar con base de datos

### Fase 4: Sistema de Consultas (Semana 3-4)

- [ ] Crear página de consulta
- [ ] Implementar formularios de síntomas, medicamentos, tratamientos
- [ ] Crear sistema de autocomplete
- [ ] Implementar gestión de archivos adjuntos
- [ ] Crear preview de archivos (PDF, imágenes)
- [ ] Validar formulario completo

### Fase 5: Generación de PDFs (Semana 4-5)

- [ ] Implementar PDFService
- [ ] Crear plantilla de receta médica
- [ ] Agregar logo y datos del doctor
- [ ] Implementar preview del PDF
- [ ] Agregar funcionalidad de impresión
- [ ] Optimizar diseño para tamaño carta

### Fase 6: Estadísticas y Gráficos (Semana 5-6)

- [ ] Implementar consultas estadísticas en BD
- [ ] Crear gráfico de pacientes por día
- [ ] Crear gráfico de síntomas más frecuentes
- [ ] Crear gráfico de medicamentos más recetados
- [ ] Crear gráfico de diagnósticos
- [ ] Implementar gráfico de ingresos
- [ ] Agregar filtros por fecha

### Fase 7: Configuraciones (Semana 6)

- [ ] Crear página de configuraciones
- [ ] Implementar formulario datos del doctor
- [ ] Agregar selector de logo
- [ ] Configurar SharedPreferences para settings
- [ ] Implementar toggle tema oscuro/claro
- [ ] Agregar validación de configuraciones

### Fase 8: Optimización y Pulimiento (Semana 7)

- [ ] Optimizar rendimiento de listas
- [ ] Implementar manejo de errores
- [ ] Agregar loading states
- [ ] Optimizar navegación
- [ ] Testear en Android y Windows
- [ ] Pulir UI/UX

### Fase 9: Funcionalidades Avanzadas (Semana 8)

- [ ] Implementar backup/restore
- [ ] Agregar búsqueda avanzada
- [ ] Optimizar autocomplete
- [ ] Implementar shortcuts de teclado (Windows)
- [ ] Agregar notificaciones locales
- [ ] Testing exhaustivo

---

## 🛠️ Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Navegación
  go_router: ^12.0.0

  # Estado
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Serialización
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1

  # Base de datos
  sqflite: ^2.3.0

  # Persistencia
  shared_preferences: ^2.2.2

  # Gráficos
  fl_chart: ^0.65.0

  # Utilidades
  intl: ^0.19.0

  # PDFs
  pdf: ^3.10.7
  printing: ^5.12.0

  # Archivos
  file_picker: ^6.1.1
  path_provider: ^2.1.1

dev_dependencies:
  # Generación de código
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  riverpod_generator: ^2.3.0
```

---

## 🎯 Características Clave

### Autocomplete Inteligente

- Búsqueda lexicográfica en tiempo real
- Persistencia de opciones frecuentes
- Sugerencias basadas en historial

### Gestión de Archivos

- Soporte PDF, PNG, JPG
- Preview integrado
- Almacenamiento local seguro

### Generación PDF Profesional

- Plantilla médica estándar
- Logo y datos personalizables
- Optimizado para impresión

### Estadísticas Avanzadas

- Gráficos interactivos
- Filtros temporales
- Métricas de rendimiento

---

## 💡 Sugerencias Adicionales

1. **Backup Automático**: Implementar exportación de datos
2. **Búsqueda Global**: Buscar en todos los datos del paciente
3. **Plantillas**: Crear plantillas para consultas frecuentes
4. **Recordatorios**: Sistema de citas y seguimientos
5. **Multi-idioma**: Soporte para español/inglés
6. **Seguridad**: Encriptación de datos sensibles

---

## 🔄 Flujo de Navegación

```
Drawer Principal
├── Lista Pacientes (/)
│   ├── Agregar Paciente (/add-patient)
│   └── Ver Paciente → Consulta (/patient/:id/consultation)
│       └── Preview PDF (/consultation/:id/preview)
├── Estadísticas (/statistics)
└── Configuraciones (/settings)
```

---

## 📊 Estimación de Tiempo

**Total estimado**: 8 semanas  
**Tiempo por día**: 4-6 horas  
**Complejidad**: Media-Alta

¿Te gustaría que profundice en alguna sección específica o tienes preguntas sobre la implementación de alguna funcionalidad?
