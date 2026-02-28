import 'package:tendria/features/unlock/domain/repositories/unlock_repository.dart';

class BlockUserUsecase {
  final UnlockRepository unlockRepository;
  BlockUserUsecase({required this.unlockRepository});
  Future<void>execute(int iduser) async {
    return await unlockRepository.blockUser(iduser);
  }
}