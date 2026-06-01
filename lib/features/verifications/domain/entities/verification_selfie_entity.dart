import 'dart:io';

class VerificationSelfieEntity {
  final String? type;
  final File foto;
  final String fotoPerfil;
  VerificationSelfieEntity({
    this.type,
    required this.foto,
    required this.fotoPerfil,
  });
}