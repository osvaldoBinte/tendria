import 'package:tendria/features/verifications/domain/entities/verifications_entity.dart';

class VerificationsModel extends VerificationsEntity {
  VerificationsModel({
    required super.type,
    super.phone,
    super.social,
  });

  factory VerificationsModel.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'] as String;
    final datos = json['datos'] as Map<String, dynamic>;

    return VerificationsModel(
      type: tipo,
      phone: tipo == 'telefono'
          ? VerificationsDataPhoneModel.fromJson(datos)
          : null,
      social: tipo == 'red_social'
          ? VerificationsDataSocialModel.fromJson(datos)
          : null,
    );
  }
  factory VerificationsModel.fromEntity(VerificationsEntity entity) {
    return VerificationsModel(
      type: entity.type,
      phone: entity.phone != null
          ? VerificationsDataPhoneModel(
              type: entity.phone!.type,
              numero: entity.phone!.numero,
              pais: entity.phone!.pais,
            )
          : null,
      social: entity.social != null
          ? VerificationsDataSocialModel(
              type: entity.social!.type,
              red: entity.social!.red,
              url: entity.social!.url,
              username: entity.social!.username,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': type,
      'datos': phone != null
          ? (phone as VerificationsDataPhoneModel).toJson()
          : (social as VerificationsDataSocialModel).toJson(),
    };
  }
}

class VerificationsDataPhoneModel extends VerificationsDataPhoneEntity {
  VerificationsDataPhoneModel({
    required super.type,
    required super.numero,
    required super.pais,
  });

  factory VerificationsDataPhoneModel.fromJson(Map<String, dynamic> json) {
    return VerificationsDataPhoneModel(
      type: json['\$type'] as String,
      numero: json['numero'] as String,
      pais: json['pais'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$type': type,
      'numero': numero,
      'pais': pais,
    };
  }
}

class VerificationsDataSocialModel extends VerificationsDataSocialEntity {
  VerificationsDataSocialModel({
    required super.type,
    required super.red,
    required super.url,
    required super.username,
  });

  factory VerificationsDataSocialModel.fromJson(Map<String, dynamic> json) {
    return VerificationsDataSocialModel(
      type: json['\$type'] as String,
      red: json['red'] as String,
      url: json['url'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$type': type,
      'red': red,
      'url': url,
      'username': username,
    };
  }
}