import 'package:tendria/features/unlock/domain/entities/unlock_entity.dart';

class UnlockModel extends UnlockEntity {
  UnlockModel({required super.iduser, required super.username, required super.profilePictureUrl, required super.age, required super.blockeddate});
  factory UnlockModel.fromJson(Map<String, dynamic> json) {
    return UnlockModel(
      iduser: json['user_id'],
      username: json['nombre'],
      profilePictureUrl: json['foto_perfil'],
      age: json['edad'],
      blockeddate: DateTime.parse(json['bloqueado_desde']),
    );
  }
  
}