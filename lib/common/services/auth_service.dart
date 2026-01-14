import 'dart:convert';
import 'package:get/get.dart';
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/features/auth/data/model/loginResponse/login_response_model.dart';
import 'package:tendria/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:tendria/framework/preferences_service.dart';

class AuthService extends GetxService {
  static final AuthService _instance = AuthService._internal();
  final PreferencesUser _prefsUser = PreferencesUser();

  LoginResponseModel? _cachedUserData;

  factory AuthService() => _instance;

  AuthService._internal();

  Future<AuthService> init() async {
    await getUserData();
    return this;
  }

  // ================================
  // Obtener datos de sesión
  // ================================
  Future<LoginResponseModel?> getUserData() async {
    if (_cachedUserData != null) return _cachedUserData;

    try {
      final sessionJson = await _prefsUser.loadPrefs(
        type: String,
        key: AppConstants.accesos,
      );

      if (sessionJson != null && sessionJson.isNotEmpty) {
        final Map<String, dynamic> sessionMap = jsonDecode(sessionJson);
        _cachedUserData = LoginResponseModel.fromJson(sessionMap);
        print('✅ Sesión cargada correctamente $sessionMap');
        return _cachedUserData;
      }

      return null;
    } catch (e) {
      print('❌ Error al obtener sesión: $e');
      return null;
    }
  }

  // ================================
  // Helpers
  // ================================
  Future<String?> getToken() async {
    final userData = await getUserData();
    return userData?.token;
  }

  Future<int?> getUserId() async {
    final userData = await getUserData();
    return userData?.userId;
  }

  // ================================
  // Guardar sesión
  // ================================
Future<bool> saveLoginResponse(LoginResponseEntity loginResponse) async {
  try {
    final modelToSave = LoginResponseModel.fromEntity(loginResponse);

    _cachedUserData = modelToSave;

     _prefsUser.savePrefs(
      type: String,
      key: AppConstants.accesos,
      value: jsonEncode(modelToSave.toJson()),
    );

    print('✅ Login guardado correctamente');
    return true;
  } catch (e) {
    print('❌ Error al guardar login: $e');
    return false;
  }
}


  // ================================
  // Estado de sesión
  // ================================
  Future<bool> isLoggedIn() async {
    final userData = await getUserData();
    return userData != null && userData.token.isNotEmpty;
  }

  // ================================
  // Logout
  // ================================
  Future<bool> logout() async {
    try {
      _cachedUserData = null;
      await _prefsUser.removePreferences();
      print('✅ Sesión cerrada correctamente');
      return true;
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      return false;
    }
  }
}
