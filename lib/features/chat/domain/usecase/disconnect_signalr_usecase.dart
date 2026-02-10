// lib/features/chat/domain/usecase/disconnect_signalr_usecase.dart

import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';

class DisconnectSignalRUsecase {
  final ChatRepository repository;

  DisconnectSignalRUsecase({required this.repository});

  Future<void> execute() async {
    return await repository.disconnectSignalR();
  }
}