
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/notification/data/model/notifications_model.dart';
import 'package:tendria/features/notification/domain/entities/notification_entity.dart';

class NotificationDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<List<NotificationEntity>> getnotification(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Notificaciones');

      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        final List data = responseDecode;

        return data.map((json) => NotificationModel.fromJson(json)).toList();
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
      print('error: $e');
      throw Exception('$e');
    }
  }

  Future<void> savetokenFCM(
      String fcm, String dispositivo, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Notificaciones/token');
      final bodyData = jsonEncode({'token': fcm, "dispositivo": dispositivo});

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: bodyData,
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

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

  Future<void> markAllNotificationsAsRead( String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Notificaciones/leer-todas');

      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

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
