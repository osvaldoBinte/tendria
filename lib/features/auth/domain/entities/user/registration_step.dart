// lib/features/auth/domain/entities/user/registration_step.dart
enum RegistrationStep {
  basicInfo,      // Pantalla 1: nombre, email, contraseñas
  personalInfo,   // Pantalla 2: fecha nacimiento, género
  physicalInfo,   // Pantalla 3: altura
  interests,      // Pantalla 4: intereses
  qualities,      // Pantalla 5: cualidades
}