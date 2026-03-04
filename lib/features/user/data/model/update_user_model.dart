
import 'dart:math';

import 'package:tendria/features/user/domain/entities/update_user_entity.dart';

class UpdateUserModel extends UpdateUserEntity {
  UpdateUserModel({
    required super.name,
    required super.dateofbirth,
    required super.gender,
    required super.bio,
    required super.heightcm,
    required super.primarylanguage,
    required super.status
  });

  factory UpdateUserModel.fromEntity(UpdateUserEntity entity) {
    return UpdateUserModel(
      name: entity.name,
      status: entity.status,
      dateofbirth: entity.dateofbirth,
      gender: entity.gender,
      bio: entity.bio,
      heightcm: entity.heightcm,
      primarylanguage: entity.primarylanguage,
    );
  }
 Map<String, dynamic> toJson() {
  return {
    'nombre': name,
    'fecha_nacimiento': dateofbirth,
    'genero': gender,
    'bio': bio,
    'altura': heightcm,
    'idioma': primarylanguage,
    if (status != null) 'status': status,
  };
}
}
