import 'package:tendria/features/stories/data/model/get/story_model.dart';
import 'package:tendria/features/stories/domain/entities/getstories/get_stories_entity.dart';

class GetStoriesModel extends GetStoriesEntity {
  GetStoriesModel({
    required super.usuarioId,
    required super.nombreUsuario,
    required super.fotoPerfilUrl,
    required super.historias,
  });

  factory GetStoriesModel.fromJson(Map<String, dynamic> json) {
    return GetStoriesModel(
      usuarioId: json['usuarioId'],
      nombreUsuario: json['nombreUsuario'],
      fotoPerfilUrl: json['fotoPerfilUrl'],
      historias: (json['historias'] as List)
          .map((e) => StoryModel.fromJson(e))
          .toList(),
    );
  }
}
