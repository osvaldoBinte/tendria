import 'package:tendria/features/user/data/model/preferences_model.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';

class GetUserModel extends GetUserEntity {
  GetUserModel({  super.id, required super.name, required super.age, required super.fotoUrl, required super.bio, required super.assets, required super.qualitiesIds, required super.interestsIds, required super.preferences});
 factory GetUserModel.fromJson(Map<String, dynamic> json) {
  return GetUserModel(
    id: json['id'],
    name: json['nombre'],
    age: json['edad'],
    fotoUrl: json['fotoUrl'],
    bio: json['bio'],

    assets: (json['media'] as List<dynamic>?)
        ?.map((e) => AssetEntity(
              id: e['id'],
              url: e['url'],
              type: e['tipo'],
              orden: e['orden'],
            ))
        .toList(),

    qualitiesIds: (json['cualidades'] as List<dynamic>?)
        ?.map((e) => QualitiesIdsEntity(
              id: e['id'],
              name: e['nombre'],
            ))
        .toList(),

    interestsIds: (json['intereses'] as List<dynamic>?)
        ?.map((e) => InterestsIdsEntity(
              id: e['id'],
              name: e['nombre'],
            ))
        .toList(),

    preferences: (json['preferencias'] as List<dynamic>?)
        ?.map((e) => PreferencesModel.fromJson(e))
        .toList(),
  );
}

  factory GetUserModel.fromEntity(GetUserEntity entity) {
    return GetUserModel(
      id: entity.id,
      name: entity.name,
      age: entity.age,
      bio: entity.bio,
      fotoUrl: entity.fotoUrl,
      assets: entity.assets,
      qualitiesIds: entity.qualitiesIds,
      interestsIds: entity.interestsIds,
      preferences: entity.preferences,
    );
  }
  Map<String, dynamic> toJson() {
  return {
    'name': name,
    'age': age,
    'bio': bio,
    'fotoUrl': fotoUrl,
    'assets': assets
        ?.map((e) => {
              'id': e.id,
              'url': e.url,
              'type': e.type,
              'orden': e.orden,
            })
        .toList(),
    'qualitiesIds': qualitiesIds
        ?.map((e) => {
              'id': e.id,
              'name': e.name,
            })
        .toList(),
    'interestsIds': interestsIds
        ?.map((e) => {
              'id': e.id,
              'name': e.name,
            })
        .toList(),
  };
}

}