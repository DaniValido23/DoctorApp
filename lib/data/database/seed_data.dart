// Datos estáticos para el seeder de la base de datos
// Este archivo contiene los IDs específicos que se usarán para el seeding
// y que posteriormente se podrán eliminar de forma segura

class SeedData {
  // IDs de pacientes que se crearán (empezando desde 1000 para evitar conflictos)
  static const List<int> patientIds = [
    1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009,
    1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019
  ];

  // IDs de consultas que se crearán (empezando desde 2000)
  static const List<int> consultationIds = [
    2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009,
    2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
    2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029,
    2030, 2031, 2032, 2033, 2034, 2035, 2036, 2037, 2038, 2039,
    2040, 2041, 2042, 2043, 2044, 2045, 2046, 2047, 2048, 2049,
    2050, 2051, 2052, 2053, 2054, 2055, 2056, 2057, 2058, 2059,
    2060, 2061, 2062, 2063, 2064, 2065
  ];

  // Datos de pacientes estáticos
  static const List<Map<String, dynamic>> patients = [
    {
      'id': 1000,
      'name': 'María Carmen García López',
      'age': 45,
      'birth_date': '1979-03-15',
      'phone': '677123456',
      'email': 'maria.garcia@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1001,
      'name': 'Juan Carlos Rodríguez Fernández',
      'age': 32,
      'birth_date': '1992-07-22',
      'phone': '678234567',
      'email': 'juan.rodriguez@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1002,
      'name': 'Ana González Martín',
      'age': 28,
      'birth_date': '1996-01-10',
      'phone': '679345678',
      'email': 'ana.gonzalez@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1003,
      'name': 'Carlos Fernández Ruiz',
      'age': 52,
      'birth_date': '1972-11-05',
      'phone': '680456789',
      'email': 'carlos.fernandez@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1004,
      'name': 'Elena María López Sánchez',
      'age': 38,
      'birth_date': '1986-06-18',
      'phone': '681567890',
      'email': 'elena.lopez@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1005,
      'name': 'Miguel Ángel Martínez Díaz',
      'age': 41,
      'birth_date': '1983-09-12',
      'phone': '682678901',
      'email': 'miguel.martinez@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1006,
      'name': 'Carmen Sánchez Herrera',
      'age': 29,
      'birth_date': '1995-04-25',
      'phone': '683789012',
      'email': 'carmen.sanchez@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1007,
      'name': 'José Luis Pérez Morales',
      'age': 47,
      'birth_date': '1977-12-03',
      'phone': '684890123',
      'email': 'jose.perez@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1008,
      'name': 'Isabel Gómez Torres',
      'age': 35,
      'birth_date': '1989-08-14',
      'phone': '685901234',
      'email': 'isabel.gomez@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1009,
      'name': 'Francisco Javier Martín Castillo',
      'age': 56,
      'birth_date': '1968-02-28',
      'phone': '686012345',
      'email': 'francisco.martin@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1010,
      'name': 'Dolores Jiménez Vega',
      'age': 33,
      'birth_date': '1991-10-17',
      'phone': '687123456',
      'email': 'dolores.jimenez@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1011,
      'name': 'Antonio Ruiz Álvarez',
      'age': 44,
      'birth_date': '1980-05-09',
      'phone': '688234567',
      'email': 'antonio.ruiz@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1012,
      'name': 'Pilar Hernández Silva',
      'age': 39,
      'birth_date': '1985-11-21',
      'phone': '689345678',
      'email': 'pilar.hernandez@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1013,
      'name': 'Manuel Díaz Romero',
      'age': 26,
      'birth_date': '1998-07-06',
      'phone': '690456789',
      'email': 'manuel.diaz@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1014,
      'name': 'Rosa María Moreno Jiménez',
      'age': 42,
      'birth_date': '1982-03-30',
      'phone': '691567890',
      'email': 'rosa.moreno@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1015,
      'name': 'Luis Muñoz Castro',
      'age': 37,
      'birth_date': '1987-09-13',
      'phone': '692678901',
      'email': 'luis.munoz@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1016,
      'name': 'Teresa Álvarez Mendoza',
      'age': 31,
      'birth_date': '1993-12-08',
      'phone': '693789012',
      'email': 'teresa.alvarez@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1017,
      'name': 'Javier Romero Navarro',
      'age': 48,
      'birth_date': '1976-04-19',
      'phone': '694890123',
      'email': 'javier.romero@email.com',
      'gender': 'Masculino'
    },
    {
      'id': 1018,
      'name': 'Cristina Torres Delgado',
      'age': 30,
      'birth_date': '1994-08-02',
      'phone': '695901234',
      'email': 'cristina.torres@email.com',
      'gender': 'Femenino'
    },
    {
      'id': 1019,
      'name': 'Pedro Vargas Ortega',
      'age': 53,
      'birth_date': '1971-01-16',
      'phone': '696012345',
      'email': 'pedro.vargas@email.com',
      'gender': 'Masculino'
    }
  ];

  // Configuración de consultas por paciente
  static const Map<int, int> consultationsPerPatient = {
    1000: 2, 1001: 2, 1002: 3, 1003: 2, 1004: 4,
    1005: 2, 1006: 5, 1007: 3, 1008: 6, 1009: 2,
    1010: 3, 1011: 2, 1012: 4, 1013: 2, 1014: 3,
    1015: 5, 1016: 2, 1017: 6, 1018: 3, 1019: 4
  };

  // Datos base para generar consultas
  static const List<String> symptoms = [
    'Dolor de cabeza', 'Fiebre', 'Tos', 'Dolor abdominal', 'Náuseas',
    'Mareos', 'Fatiga', 'Dolor muscular', 'Congestión nasal', 'Dolor de garganta',
    'Insomnio', 'Dolor de espalda', 'Palpitaciones', 'Dificultad respiratoria'
  ];

  static const List<String> diagnoses = [
    'Resfriado común', 'Gastritis', 'Hipertensión', 'Migraña', 'Ansiedad',
    'Bronquitis', 'Dermatitis', 'Artritis', 'Diabetes tipo 2', 'Sinusitis',
    'Lumbalgia', 'Indigestión', 'Estrés', 'Alergia estacional'
  ];

  static const List<String> treatments = [
    'Reposo', 'Hidratación abundante', 'Dieta blanda', 'Ejercicio moderado',
    'Compresas frías', 'Compresas calientes', 'Fisioterapia', 'Relajación',
    'Evitar irritantes', 'Control de peso', 'Técnicas de respiración'
  ];

  static const List<Map<String, String>> medications = [
    {'name': 'Paracetamol', 'dosage': '500mg', 'frequency': 'Cada 8 horas'},
    {'name': 'Ibuprofeno', 'dosage': '400mg', 'frequency': 'Cada 6 horas'},
    {'name': 'Amoxicilina', 'dosage': '500mg', 'frequency': 'Cada 8 horas'},
    {'name': 'Omeprazol', 'dosage': '20mg', 'frequency': 'Una vez al día'},
    {'name': 'Loratadina', 'dosage': '10mg', 'frequency': 'Una vez al día'},
    {'name': 'Diclofenaco', 'dosage': '50mg', 'frequency': 'Cada 12 horas'},
    {'name': 'Acetaminofén', 'dosage': '650mg', 'frequency': 'Cada 6 horas'},
    {'name': 'Cetirizina', 'dosage': '10mg', 'frequency': 'Una vez al día'},
    {'name': 'Ranitidina', 'dosage': '150mg', 'frequency': 'Cada 12 horas'},
    {'name': 'Metformina', 'dosage': '850mg', 'frequency': 'Cada 12 horas'},
  ];

  static const List<double> priceOptions = [
    200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500
  ];

  static const List<String?> instructionOptions = [
    'Tomar con alimentos',
    'Tomar en ayunas',
    'Evitar alcohol',
    'Tomar con abundante agua',
    'No superar la dosis indicada',
    null,
  ];

  static const List<String?> observationOptions = [
    'Paciente refiere mejora con el tratamiento anterior',
    'Se recomienda seguimiento en 15 días',
    'Continuar con medidas preventivas',
    'Paciente presenta síntomas leves',
    'Se observa evolución favorable',
    null,
  ];
}