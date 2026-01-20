class GetUserEntity {
  final String? name;
  final String? age;
  final String? fotoUrl;
  final List<Asset>? assets;
  final List<QualitiesIds>? qualitiesIds;
  final List<InterestsIds>? interestsIds;
  GetUserEntity({
     this.name,
     this.age,
     this.fotoUrl,
     this.assets,
     this.qualitiesIds,
     this.interestsIds,
  });

}
class Asset {
  final int id;
  final String url;
  final String type;
  final String orden;

  Asset({required this.id, required this.url, required this.type, required this.orden});
}
class QualitiesIds {
  final int id;
  final String name;

  QualitiesIds({required this.id, required this.name});
}
class InterestsIds {
  final int id;
  final String name;  
  InterestsIds({required this.id, required this.name});
}