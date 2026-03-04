import 'package:tendria/features/user/domain/entities/update_location_entity.dart';

class UpdateLocationModel extends UpdateLocationEntity {
  UpdateLocationModel({required super.latitude, required super.longitude, required super.city});

  factory UpdateLocationModel.fromJson(Map<String, dynamic> json) {
    return UpdateLocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
    );
  }
  factory UpdateLocationModel.fromEntity(UpdateLocationEntity entity) {
    return UpdateLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      city: entity.city,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'ciudad': city,
    };
  }
}