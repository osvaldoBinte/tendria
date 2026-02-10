import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';

class StoryModel extends StoryEntity {
  StoryModel({
    required super.id,
    required super.tipoContenido,
    required super.urlContenido,
    required super.fechaCreacion,
    required super.fechaExpiracion,
    required super.vistas,
    required super.likes,
    required super.yaVista,
    required super.yaLikeada,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      tipoContenido: json['tipoContenido'],
      urlContenido: json['urlContenido'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaExpiracion: DateTime.parse(json['fechaExpiracion']),
      vistas: json['vistas'],
      likes: json['likes'],
      yaVista: json['yaVista'],
      yaLikeada: json['yaLikeada'],
    );
  }

}
