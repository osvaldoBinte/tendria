import 'package:tendria/features/stories/data/model/get/get_stories_model.dart';
import 'package:tendria/features/stories/data/model/get/story_model.dart';
import 'package:tendria/features/stories/data/model/post/post_stories_model.dart';
import 'package:tendria/features/stories/domain/entities/getstories/get_stories_entity.dart';
import 'package:tendria/features/stories/domain/entities/getstories/story_entity.dart';
import 'package:tendria/features/stories/domain/entities/post/post_stories_entity.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';

class StoriesDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<void> addLikeToStory(int id, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Historias/$id/like');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
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

  Future<void> createStrory(PostStoriesEntity entity, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Historias');

      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      final model = PostStoriesModel.fromEntity(entity);

      model.addFieldsToRequest(request);

      await model.addFileToRequest(request);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }

      throw Exception('Error procesando procedimiento: $e');
    }
  }

  Future<List<GetStoriesEntity>> fetchStories(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Historias/matches');
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        final List data = responseDecode;
        return data.map((json) => GetStoriesModel.fromJson(json)).toList();
      }

      throw ApiExceptionCustom(response: response);
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }
Future<List<StoryEntity>> fetchStoriesbyid(int id, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/Historias/user/$id');

    print('➡️ URL: $url');
    print('➡️ Token: $token');

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    print('⬅️ Status Code: ${response.statusCode}');
    print('⬅️ Body (raw): ${response.body}');

    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      print('⬅️ Body (UTF8): $dataUTF8');

      final responseDecode = jsonDecode(dataUTF8);
      print('⬅️ JSON Decodificado: $responseDecode');

      final List data = responseDecode;
      print('⬅️ Lista parseada: $data');

      return data.map((json) {
        print('🔄 Procesando item: $json');
        return StoryModel.fromJson(json);
      }).toList();
    }

    print('❌ Error: ${response.statusCode} - ${response.body}');
    throw ApiExceptionCustom(response: response);

  } catch (e) {
    print('🔥 Excepción capturada: $e');

    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      throw Exception(convertMessageException(error: e));
    }

    throw Exception('$e');
  }
}

  Future<void> removeStory(int id, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Historias/$id');

      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
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

  Future<void> setStoryAsSeen(int historiaId, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Historias/$historiaId/vista');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
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
}
