import 'package:tendria/features/verifications/data/model/verification_selfie_model.dart';
import 'package:tendria/features/verifications/data/model/verifications_model.dart';
import 'package:tendria/features/verifications/domain/entities/get_verification_entity.dart';

class GetVerificationModel extends GetVerificationEntity {
  GetVerificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.estado,
    required super.createdAt,
    required super.updatedAt,
    super.phone,
    super.social,
  //  super.selfie,
    super.revisadoEn,
  });

  factory GetVerificationModel.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'] as String;
    final datos = json['datos'] as Map<String, dynamic>;

    return GetVerificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: tipo,
      estado: json['estado'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      revisadoEn: json['revisado_en'] != null
          ? DateTime.parse(json['revisado_en'] as String)
          : null,
      phone: tipo == 'telefono'
          ? VerificationsDataPhoneModel.fromJson(datos)
          : null,
      social: tipo == 'red_social'
          ? VerificationsDataSocialModel.fromJson(datos)
          : null,
     // selfie: tipo == 'selfie' ? VerificationSelfieModel.fromJson(datos) : null,
    );
  }
}
