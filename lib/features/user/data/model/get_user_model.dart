import 'package:tendria/features/user/domain/entities/get_user_entity.dart';

class GetUserModel extends GetUserEntity {
  GetUserModel({required super.name, required super.age, required super.fotoUrl, required super.assets, required super.qualitiesIds, required super.interestsIds});
  
  factory GetUserModel.fromJson(Map<String, dynamic> json) {
    return GetUserModel(
      name: json['name'],
      age: json['age'],
      fotoUrl: json['fotoUrl'],
      assets: (json['assets'] as List<dynamic>?)
          ?.map((e) => Asset(
                id: e['id'],
                url: e['url'],
                type: e['type'],
                orden: e['orden'],
              ))
          .toList(),
      qualitiesIds: (json['qualitiesIds'] as List<dynamic>?)
          ?.map((e) => QualitiesIds(
                id: e['id'],
                name: e['name'],
              ))
          .toList(),
      interestsIds: (json['interestsIds'] as List<dynamic>?)
          ?.map((e) => InterestsIds(
                id: e['id'],
                name: e['name'],
              ))
          .toList(),
    );
  }
  factory GetUserModel.fromEntity(GetUserEntity entity) {
    return GetUserModel(
      name: entity.name,
      age: entity.age,
      fotoUrl: entity.fotoUrl,
      assets: entity.assets,
      qualitiesIds: entity.qualitiesIds,
      interestsIds: entity.interestsIds,
    );
  }
  Map<String, dynamic> toJson() {
  return {
    'name': name,
    'age': age,
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