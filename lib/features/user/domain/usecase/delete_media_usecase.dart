import 'package:tendria/features/user/domain/repositories/user_repository.dart';

class DeleteMediaUsecase {
  final UserRepository userRepository;

  DeleteMediaUsecase({ required this.userRepository});

  Future<void> execute(int mediaId) async {
    return await userRepository.deleteMedia(mediaId);
  }
}