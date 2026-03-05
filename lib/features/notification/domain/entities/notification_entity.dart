class NotificationEntity {
  final int notificationId;
  final String type;
  final String title;
  final String message;
  final String? imageUrl;
  final String? linkUrl;
  final String? createdAt;
  final bool read;
 final Map<String, dynamic> metadata;

  NotificationEntity({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    this.linkUrl,
    required this.createdAt,
    required this.read,
    required this.metadata,
  });
}
