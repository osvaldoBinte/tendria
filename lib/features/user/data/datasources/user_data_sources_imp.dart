import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/user/data/model/get_user_model.dart';
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';

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
       if (e is SocketException || e is http.ClientException || e is TimeoutException) {

        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
  
    }
  }
  
}