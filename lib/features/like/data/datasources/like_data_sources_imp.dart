import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/like/data/model/liked_by_users_model.dart';
import 'package:tendria/features/like/data/model/matches_model.dart';
import 'package:tendria/features/like/domain/entities/liked_by_users_entity.dart';
import 'package:tendria/features/like/domain/entities/matches_entity.dart';

class LikeDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<List<LikedByUsersEntity>> getLikedByUsers(int postId,String token) async {
      try {
      Uri url = Uri.parse('$defaultApiServer/Likes/usuarios-interesados');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.statusCode == 200) {
          final dataUTF8 = utf8.decode(response.bodyBytes);
          final responseDecode = jsonDecode(dataUTF8);

          final List data = responseDecode;
          return data.map((json) => LikedByUsersModel.fromJson(json)).toList();
        }
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


  Future<List<MatchesEntity>> myMatch(String token)  async{
    try {
      Uri url = Uri.parse('$defaultApiServer/Likes/mis-matches');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.statusCode == 200) {
          final dataUTF8 = utf8.decode(response.bodyBytes);
          final responseDecode = jsonDecode(dataUTF8);

          final List data = responseDecode;
          return data.map((json) => MatchesModel.fromJson(json)).toList();
        }
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


  Future<void> toggleLike(int userId, bool liked,String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Likes/dar-like');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':'Bearer $token'
        },
        body: jsonEncode({
          'to_user': userId,
          'liked': liked,
        }),
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