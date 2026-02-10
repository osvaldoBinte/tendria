import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class UploadPicturePerfileUsecase {
  UserRepository userRepository;
  UploadPicturePerfileUsecase({required this.userRepository});
  Future<void> execute(String file) async {
   return await userRepository.uploadPicturePerfile(file);
  }
}