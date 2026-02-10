class LikedByUsersEntity {
  final int fromusererId;
  final String username;
  final String profilePictureUrl;
  final int ega;
  final DateTime likedAt;

  LikedByUsersEntity({
    required this.fromusererId,
    required this.username,
    required this.profilePictureUrl,
    required this.ega,
    required this.likedAt,
  });
}