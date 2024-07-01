import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/features/authentication/data/authentication_data_source/authentication_api.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/network/network_provider.dart';


final authenticationApiProvider = Provider<Authentication>((ref) => AuthenticationImpl(ref));

class AuthenticationImpl implements Authentication{

  final Ref _ref;

  AuthenticationImpl(this._ref);


  @override
  Future<Response> generateOtp({required String pathParam, required Map<String, dynamic> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_get_otp $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> validateOtp({required String pathParam, required  Map<String, dynamic> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_validate_otp $error');
      throw DataException.fromDioError(error);
    }
  }
  
  @override
  Future<Response> createPin({required String pathParam ,required Map<String, dynamic> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_create_pin $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> getUserData({required String pathParam, required  Map<String, dynamic> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_get_User_Data $error');
      throw DataException.fromDioError(error);
    }
  }
}