import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/user/data/model/get_user_model.dart';
import 'package:tendria/features/user/data/model/preferences_model.dart';
import 'package:tendria/features/user/data/model/upload_media_model.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
import 'package:tendria/features/user/domain/entities/preferences_entity.dart';
import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';

class UserDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;
  Future<GetUserEntity> getuser(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/User/mi-perfil');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        return GetUserModel.fromJson(responseDecode);
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }


  }



  Future<List<GetUserEntity>> getNearbyUsers(int pageNumber,int pageSize,String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/usuarios-cercanos?pageNumber=$pageNumber&pageSize=$pageSize');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

  if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        final List doctores = responseDecode['items'];
        return doctores
            .map((json) => GetUserModel.fromJson(json))
            .toList();
      }

    final exception = ApiExceptionCustom(response: response);
    exception.validateMesage();
    throw exception;

  } catch (e) {
    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      throw Exception(convertMessageException(error: e));
    }
    throw Exception(e.toString());
  }
}

Future<void> preferencesUser(PreferencesEntity entity, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/preferencias');

    final model = PreferencesModel.fromEntity(entity);
    final bodyData = jsonEncode(model.toJson());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: bodyData,
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
 
      return;
    }

    ApiExceptionCustom exception = ApiExceptionCustom(response: response);
    exception.validateMesage();
    throw exception;
  } catch (e, stackTrace) {

    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      final message = convertMessageException(error: e);
      throw Exception(message);
    }

    throw Exception('$e');
  }
}


Future<void> createMedia(
  List<UploadMediaEntity> entities,
  String token,
) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/upload-media');

    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    for (var entity in entities) {
      final model = UploadMediaModel.fromEntity(entity);

      try {
        await model.addFileToRequest(request); 
      } catch (e) {
        print('❌ Archivo no permitido: ${entity.mediaPath}');
        throw Exception(
          'Solo se permiten imágenes (jpg, png, gif, webp) para subir'
        );
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
    }

    print("✅ Media(s) subida(s) correctamente");

  } catch (e) {
    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      throw Exception(convertMessageException(error: e));
    }

    throw Exception('Error procesando procedimiento: $e');
  }
}


Future<void> uploadPicturePerfil(
  String file,
  String token,
) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/cambiar-foto-perfil');

    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file,
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Error HTTP ${response.statusCode}: ${response.body}',
      );
    }

    print('✅ Foto de perfil actualizada correctamente');

  } catch (e) {
    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      throw Exception(convertMessageException(error: e));
    }

    throw Exception('Error cambiando foto de perfil: $e');
  }
}

}
