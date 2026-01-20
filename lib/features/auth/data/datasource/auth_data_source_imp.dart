import 'package:tendria/common/constants/constants.dart';
import 'package:tendria/common/errors/api_errors.dart';
import 'package:tendria/features/auth/data/model/loginResponse/login_response_model.dart';
import 'package:tendria/features/auth/data/model/user/create_user_model.dart';
import 'package:tendria/features/user/data/model/get_user_model.dart';
import 'package:tendria/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:tendria/features/auth/domain/entities/user/create_user_entity.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tendria/features/user/domain/entities/get_user_entity.dart';
class AuthDataSourceImp {
      String defaultApiServer = AppConstants.serverBase;

  @override
  Future<LoginResponseEntity> login(String email, String password) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Auth/login');
      final bodyData = jsonEncode({
        'email': email, 
        'password': password, 
      });
      
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: bodyData
      );
      
     if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
      final responseDecode = jsonDecode(dataUTF8);
      
      return LoginResponseModel.fromJson(responseDecode);
       
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

  @override
  Future<void> createuser(CreateUserEntity entity) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Auth/registrar');
      
      
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
          body:
            jsonEncode(CreateUserModel.fromEntity(entity).toJson()),
      );
      
    if (response.statusCode == 200 || response.statusCode == 201) {
        return;
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