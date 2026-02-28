import 'package:tendria/features/like/domain/entities/pending_chat_entity.dart';

class PendingChatModel extends PendingChatEntity {
  PendingChatModel({
    required super.chatId,
    required super.userId,
    super.name,
    super.photoUrl,
    super.age,
    super.hiddenMessage,
    required super.createdAt,
    required super.unlockCost,
  });

  factory PendingChatModel.fromJson(Map<String, dynamic> json) {
    return PendingChatModel(
      chatId: json['chatId'],
      userId: json['usuarioId'],
      name: json['nombre'], 
      photoUrl: json['fotoUrl'],
      age: json['edad'], 
      hiddenMessage: json['mensajeOculto'], 
      createdAt: DateTime.parse(json['fechaCreacion']), 
      unlockCost: (json['costoDesbloqueo'] as num).toDouble(), 
    );
  }
}
