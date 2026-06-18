import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String serverBase = dotenv.env['API_BASE'].toString();
  static const String accesos = "accesostendria";
   static   const String tutorialKey = 'has_seen_tutdorial';

  static const String reviewRequestedKey = 'review_requesteds';

static const String  appStoreId  = 'XXXXXXXXXX';      
static const String  playStoreId = 'dev.binteconsulting.tendria';  
  static const String startTutorialKey = 'start_tutorial_seen';
    static const String profileTutorialKey = 'profile_tutorial_seen';
  static const String updateProfileTutorialKey = 'update_profile_tutorial_seend';

}