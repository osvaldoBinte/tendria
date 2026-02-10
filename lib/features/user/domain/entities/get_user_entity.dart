import 'package:tendria/features/user/domain/entities/preferences_entity.dart';

class GetUserEntity {
  final int? id;
  final String? name;
  final int? age;
  final String? fotoUrl;
  final String? bio;
  final List<AssetEntity>? assets;
  final List<QualitiesIdsEntity>? qualitiesIds;
  final List<InterestsIdsEntity>? interestsIds;
  final List<PreferencesEntity>? preferences;
  GetUserEntity({
       this.id,
     this.name,
     this.age,
     this.fotoUrl,
     this.assets,
      this.bio,
     this.qualitiesIds,
     this.interestsIds,
      this.preferences,
  });

}
class AssetEntity {
  final int id;
  final String url;
  final String type;
  final int orden;

  AssetEntity({required this.id, required this.url, required this.type, required this.orden});
}
class QualitiesIdsEntity {
  final int id;
  final String name;

  QualitiesIdsEntity({required this.id, required this.name});
}

class InterestsIdsEntity {
  final int id;
  final String name;  
  InterestsIdsEntity({required this.id, required this.name});
}