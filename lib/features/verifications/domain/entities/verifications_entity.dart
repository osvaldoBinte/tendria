class VerificationsEntity {
  final String type;
  final VerificationsDataPhoneEntity? phone;
  final VerificationsDataSocialEntity? social;
  VerificationsEntity({
    required this.type,
    this.phone,
    this.social,
  });
}
class VerificationsDataPhoneEntity {
  final String type; 
  final String numero;
  final String pais;
  
  VerificationsDataPhoneEntity({
    required this.type,
    required this.numero,
    required this.pais,
  });
}
class VerificationsDataSocialEntity {
  final String type; 
  final String red;
  final String url;
  final String username;
  
  VerificationsDataSocialEntity({
    required this.type,
    required this.red,
    required this.url,
    required this.username,
  });
}