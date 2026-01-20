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

  Future<List<CatalogEntity>> getInterests() async {
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
}
