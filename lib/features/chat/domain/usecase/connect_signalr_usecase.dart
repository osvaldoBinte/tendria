
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class ConnectSignalRUsecase {
  final ChatRepository chatRepository;

  ConnectSignalRUsecase({required this.chatRepository});

  Future<void> execute(String token) async {
    return await chatRepository.connectSignalR(token);
  }
}