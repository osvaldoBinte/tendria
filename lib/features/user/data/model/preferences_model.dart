import 'package:tendria/features/user/domain/entities/preferences_entity.dart';

class PreferencesModel extends PreferencesEntity {
  PreferencesModel({
    required super.agemin,
    required super.agemax,
    required super.searchgender,
    required super.connectiontype,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      agemin: json['edad_min'],
      agemax: json['edad_max'],
      searchgender: json['busca_genero'],
      connectiontype: json['tipo_conexion'],
    );
  }
  factory PreferencesModel.fromEntity(PreferencesEntity entity) {
    return PreferencesModel(
      agemin: entity.agemin,
      agemax: entity.agemax,
      searchgender: entity.searchgender,
      connectiontype: entity.connectiontype,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'edad_min': agemin,
      'edad_max': agemax,
      'busca_genero': searchgender,
      'tipo_conexion': connectiontype,
    };
  }
}
