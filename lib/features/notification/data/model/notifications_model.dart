
import 'package:tendria/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.notificationId,
    required super.type,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.read,
    super.imageUrl,
    super.linkUrl,
    required super.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificacionId'] ?? 0,
      type: json['tipo'] ?? '',
      title: json['titulo'] ?? '',
      message: json['mensaje'] ?? '',
      imageUrl: json['imagenUrl'], 
      linkUrl: json['enlaceUrl'],
      createdAt: json['fechaCreacion'] ?? '',
      read: json['leida'] ?? false,
      metadata: json['metadatos'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificacionId': notificationId,
      'tipo': type,
      'titulo': title,
      'mensaje': message,
      'imagenUrl': imageUrl,
      'enlaceUrl': linkUrl,
      'fechaCreacion': createdAt,
      'leida': read,
      'metadatos': metadata,
    };
  }
}