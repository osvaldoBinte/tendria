abstract class FacebookRepository {
  Future<void> logRegister({required String method});
  Future<void> logLogin({required String method});
  Future<void> logMatch({required String targetUserId});
  Future<void> logViewProfile({required String targetUserId});
}