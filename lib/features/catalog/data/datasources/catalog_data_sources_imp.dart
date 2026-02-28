import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/catalog/data/model/catalog_model.dart';
import 'package:tendria/features/catalog/domain/entities/catalog_entity.dart';
import 'package:http/http.dart' as http;

class CatalogDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<List<CatalogEntity>> getQualities() async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Catalogos/cualidades');
      final response = await http.get(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        final List data = responseDecode;
        return data.map((json) => CatalogModel.fromJson(json)).toList();
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

  Future<List<CatalogEntity>> getInterests() async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Catalogos/intereses');
      final response = await http.get(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        final List data = responseDecode;
        return data.map((json) => CatalogModel.fromJson(json)).toList();
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
  Future<void> postInterests(List<int> interestsIds, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/intereses');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(interestsIds),
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
      throw Exception(convertMessageException(error: e));
    }
    throw Exception('$e');
  }
}

Future<void> postQualities(List<int> qualitiesIds,String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/cualidades');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(qualitiesIds),
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
      throw Exception(convertMessageException(error: e));
    }
    throw Exception('$e');
  }
}

  Future<void> deleteInterests(List<int> interestsIds, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/intereses');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(interestsIds),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
  } catch (e, stackTrace) {

    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      throw Exception(convertMessageException(error: e));
    }
    throw Exception('$e');
  }
}

Future<void> deleteQualities(List<int> qualitiesIds,String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/User/cualidades');
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(qualitiesIds),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
  } catch (e, stackTrace) {

    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      throw Exception(convertMessageException(error: e));
    }
    throw Exception('$e');
  }
}
}
