import 'package:tendria/features/like/domain/entities/matches_entity.dart';

class MatchesModel extends MatchesEntity {
  MatchesModel({ required super.userId,  super.name,  super.photoUrl, required super.chatId, required super.matchedAt});
  

  factory MatchesModel.fromJson(Map<String, dynamic> json) {
    return MatchesModel(
      userId: json['usuarioId'],
      name: json['nombre'],
      photoUrl: json['fotoUrl'],
      chatId: json['chatId'],
      matchedAt: DateTime.parse(json['fechaMatch']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'usuarioId': userId,
      'nombre': name,
      'fotoUrl': photoUrl,
      'chatId': chatId,
      'fechaMatch': matchedAt.toIso8601String(),
    };
  }
  factory MatchesModel.fromEntity(MatchesEntity entity) {
    return MatchesModel(
      userId: entity.userId,
      name: entity.name,
      photoUrl: entity.photoUrl,
      chatId: entity.chatId,
      matchedAt: entity.matchedAt,
    );
  }
}