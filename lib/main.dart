import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tendria/app.dart';
import 'package:tendria/common/settings/enviroment.dart';
import 'package:tendria/framework/preferences_service.dart';

String enviromentSelect = Enviroment.testing.value;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=========ENVIROMENT SELECTED: $enviromentSelect');
  await dotenv.load(fileName: enviromentSelect);
  await PreferencesUser().initiPrefs();

  runApp(const App());
}
 