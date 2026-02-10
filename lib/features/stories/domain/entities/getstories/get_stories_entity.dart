import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';

class GetStoriesEntity {
  final int doctorId;
  final String nombreDoctor;
  final String fotoPerfilUrl;
  final List<StoryEntity> historias;

  GetStoriesEntity({
    required this.doctorId,
    required this.nombreDoctor,
    required this.fotoPerfilUrl,
    required this.historias,
  });

}
