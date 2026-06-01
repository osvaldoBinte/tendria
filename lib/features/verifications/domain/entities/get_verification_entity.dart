import 'package:tendria/features/verifications/domain/entities/verification_selfie_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verifications_entity.dart';

class GetVerificationEntity {
  final int id;
  final int userId;
  final String type;
  final String estado;
  final VerificationsDataPhoneEntity? phone;
  final VerificationsDataSocialEntity? social;
  final VerificationSelfieEntity? selfie;
  final DateTime? revisadoEn;
  final DateTime createdAt;
  final DateTime updatedAt;

  GetVerificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.estado,
    this.phone,
    this.social,
    this.selfie,
    this.revisadoEn,
    required this.createdAt,
    required this.updatedAt,
  });
} 
