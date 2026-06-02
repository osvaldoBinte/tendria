import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/purchase/data/model/purchase_apple_model.dart';
import 'package:tendria/features/purchase/data/model/purchase_google_model.dart';
import 'package:tendria/features/purchase/data/model/purchase_model.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_apple_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_entity.dart';
import 'package:tendria/features/purchase/domain/entity/purchase_google_entity.dart';

class PurchaseDataSourcesImp {
    String defaultApiServer = AppConstants.serverBase;

  Future<List<PurchaseEntity>> getPurchases( String token) async {
      try {
      Uri url = Uri.parse('$defaultApiServer/Compras/productos');

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
          return data.map((json) => PurchaseModel.fromJson(json)).toList();
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


Future<void> purchaseApple(PurchaseAppleEntity entity, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/Compras/verificar/apple');
 

    final body = jsonEncode(PurchaseAppleModel.fromEntity(entity).toJson());
 

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
 

    if (response.statusCode == 200 || response.statusCode == 201) {
     
      return;
    }
 
    ApiExceptionCustom exception = ApiExceptionCustom(response: response);
    exception.validateMesage();
    throw exception;

  } catch (e) {
    print('🔥 Exception capturada: $e');

    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {

      final message = convertMessageException(error: e);
      print('⚠️ Error de red: $message');

      throw Exception(message);
    }

    throw Exception('$e');
  }
}
  Future<void> purchaseGoogle(PurchaseGoogleEntity entity ,String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Compras/verificar/google');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(PurchaseGoogleModel.fromEntity(entity).toJson()),
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