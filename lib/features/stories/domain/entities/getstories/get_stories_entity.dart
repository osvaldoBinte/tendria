import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';

class GetStoriesEntity {
  final int usuarioId;
  final String nombreUsuario;
  final String fotoPerfilUrl;
  final List<StoryEntity> historias;

  GetStoriesEntity({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.fotoPerfilUrl,
    required this.historias,
  });

}
