import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/unlock/data/model/unlock_model.dart';
import 'package:tendria/features/unlock/domain/entities/unlock_entity.dart';

class UnlockDatasourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<void> blockUser(int iduser, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Bloqueos/bloquear/$iduser');
      final response = await http.post(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if(response.statusCode == 200 || response.statusCode == 201){
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
    Future<void> unblockUser(int iduser, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Bloqueos/desbloquear/$iduser');
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if(response.statusCode == 200 || response.statusCode == 201){
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
  Future<List<UnlockEntity>> fetchBlockedUsers(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Bloqueos/bloqueados');
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
       final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        final List data = responseDecode['usuarios_bloqueados'];
        return data
            .map((json) => UnlockModel.fromJson(json))
            .toList();
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
