import 'package:tendria/features/chat/domain/repositories/chat_repository.dart';
import 'package:tendria/features/like/domain/repositories/like_repository.dart';

class PaymentsChatUsecase {
  final LikeRepository likeRepository;

  PaymentsChatUsecase({ required this.likeRepository});

  Future<void> execute(int chatId) async {
    return await likeRepository.paymentsChat(chatId);
  }
}