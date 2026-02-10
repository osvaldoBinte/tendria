
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class ConnectSignalRUsecase {
  final ChatRepository repository;

  ConnectSignalRUsecase({required this.repository});

  Future<void> execute(String token) async {
    return await repository.connectSignalR(token);
  }
}