import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookDatasourcesImp {
  final FacebookAppEvents _facebookAppEvents;

  FacebookDatasourcesImp({FacebookAppEvents? facebookAppEvents})
      : _facebookAppEvents = facebookAppEvents ?? FacebookAppEvents();

  Future<void> logRegister({required String method}) async {
    await _facebookAppEvents.logCompletedRegistration(
      registrationMethod: method,
    );
  }

  Future<void> logLogin({required String method}) async {
    await _facebookAppEvents.logEvent(
      name: 'fb_mobile_login',
      parameters: {
        'fb_login_method': method,
      },
    );
  }

  Future<void> logMatch({required String targetUserId}) async {
    await _facebookAppEvents.logEvent(
      name: 'tendria_match',
      parameters: {
        'target_user_id': targetUserId,
      },
    );
  }

  Future<void> logViewProfile({required String targetUserId}) async {
    await _facebookAppEvents.logViewContent(
      id: targetUserId,
      type: 'profile',
    );
  }
}