import 'package:tendria/features/unlock/domain/repositories/unlock_repository.dart';

class UnblockUserUsecase {
  final UnlockRepository unlockRepository;
  UnblockUserUsecase({required this.unlockRepository});
  Future<void>execute(int iduser) async {
    return await unlockRepository.unblockUser(iduser);
  }
}