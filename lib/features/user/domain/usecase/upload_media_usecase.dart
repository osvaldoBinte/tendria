import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';
import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class UploadMediaUsecase {
  UserRepository userRepository;
  UploadMediaUsecase({required this.userRepository});
  Future<void> execute(List<UploadMediaEntity> entities) async {
    return await userRepository.uploadMedia(entities);
  }
}