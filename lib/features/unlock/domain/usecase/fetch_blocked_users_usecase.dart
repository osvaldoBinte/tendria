import 'package:tendria/features/unlock/domain/entities/unlock_entity.dart';
import 'package:tendria/features/unlock/domain/repositories/unlock_repository.dart';

class FetchBlockedUsersUsecase {
  final UnlockRepository unlockRepository;
  FetchBlockedUsersUsecase({required this.unlockRepository});
  Future<List<UnlockEntity>>execute() async {
    return await unlockRepository.fetchBlockedUsers();
  }
}