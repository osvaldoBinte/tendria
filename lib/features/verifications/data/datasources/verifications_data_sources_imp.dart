import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/verifications/data/model/get_verification_model.dart';
import 'package:tendria/features/verifications/data/model/verification_selfie_model.dart';
import 'package:tendria/features/verifications/data/model/verifications_model.dart';
import 'package:tendria/features/verifications/domain/entities/get_verification_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verification_selfie_entity.dart';
import 'package:tendria/features/verifications/domain/entities/verifications_entity.dart';

class VerificationsDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<void> verificationselfie(
    VerificationSelfieEntity entity,
    String token,
  ) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Verifications/selfie');

      final request = await VerificationSelfieModel.fromEntity(
        entity,
      ).toMultipartRequest(url);

      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

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

  Future<void> verification(
    VerificationsEntity verification,
    String token,
  ) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Reportes');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(VerificationsModel.fromEntity(verification).toJson()),
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
        print('🌐 Error de red detectado');
        throw Exception(convertMessageException(error: e));
      }

      throw Exception('$e');
    }
  }
  Future<List<GetVerificationEntity>> getVerifications(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Verifications/my-status');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => GetVerificationModel.fromJson(json))
            .toList();
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        print('🌐 Error de red detectado');
        throw Exception(convertMessageException(error: e));
      }

      throw Exception('$e');
    }
  }
}
