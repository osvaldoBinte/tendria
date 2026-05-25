 
import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class DisconnectSignalRUsecase {
  final ChatRepository chatRepository;

  DisconnectSignalRUsecase({required this.chatRepository});

  Future<void> execute() async {
    return await chatRepository.disconnectSignalR();
  }
}