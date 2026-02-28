import 'package:tendria/features/user/domain/entities/preferences_entity.dart';

class PreferencesModel extends PreferencesEntity {
  PreferencesModel({
    required super.agemin,
    required super.agemax,
    required super.searchgender,
    required super.connectiontype,
      super.distancekm,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      agemin: json['edad_min'],
      agemax: json['edad_max'],
      searchgender: json['busca_genero'],
      connectiontype: json['tipo_conexion'],
distancekm: (json['distancia_km'] as num?)?.toDouble(),
    );
  }
  factory PreferencesModel.fromEntity(PreferencesEntity entity) {
    return PreferencesModel(
      agemin: entity.agemin,
      agemax: entity.agemax,
      searchgender: entity.searchgender,
      connectiontype: entity.connectiontype,
      distancekm: entity.distancekm,
    );
  }

 Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = {
    'busca_genero': searchgender,
    'tipo_conexion': connectiontype,
  };

  if (agemin != null) {
    data['edad_min'] = agemin;
  }

  if (agemax != null) {
    data['edad_max'] = agemax;
  }
  if (distancekm != null) {
    data['distancia_km'] = distancekm;
  }
  return data;
}
}
