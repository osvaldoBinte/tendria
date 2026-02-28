class UnlockEntity {
  final int iduser;
  final String? username;
  final String? profilePictureUrl;
  final int? age;
  final DateTime? blockeddate;
  UnlockEntity({
    required this.iduser,
     this.username,
     this.profilePictureUrl,
     this.age,
     this.blockeddate,
  });
}