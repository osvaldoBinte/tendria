import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';

class LikedByUsersModel extends LikedByUsersEntity {
  LikedByUsersModel({required super.fromusererId, required super.username, required super.profilePictureUrl, required super.ega, required super.likedAt});
  factory LikedByUsersModel.fromJson(Map<String, dynamic> json) {
    return LikedByUsersModel(
      fromusererId: json['from_user'],
      username: json['nombre'],
      profilePictureUrl: json['fotoUrl'],
      ega: json['edad'],
      likedAt: DateTime.parse(json['creado_en']),
    );
  }
}