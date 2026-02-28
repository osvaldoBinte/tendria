import 'package:tendria/features/unlock/domain/entities/unlock_entity.dart';

abstract class UnlockRepository {

    Future<void>blockUser(int iduser);
    Future<void>unblockUser(int iduser);
    Future<List<UnlockEntity>>fetchBlockedUsers();
}