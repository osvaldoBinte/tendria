class MatchesEntity {
  final String? name;
  final String? photoUrl;
  final int userId;
  final int chatId;
  final DateTime matchedAt;

  MatchesEntity({
    required this.userId,
     this.name,
     this.photoUrl,
    required this.chatId,
    required this.matchedAt,
  });
}