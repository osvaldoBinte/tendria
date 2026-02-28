class PendingChatEntity {
  final int chatId;
  final int userId;
  final String? name;
  final String? photoUrl;
  final int? age;
  final String? hiddenMessage;
  final DateTime createdAt;
  final double unlockCost;

  PendingChatEntity({
    required this.chatId,
    required this.userId,
    this.name,
    this.photoUrl,
    this.age,
    this.hiddenMessage,
    required this.createdAt,
    required this.unlockCost,
  });
}
