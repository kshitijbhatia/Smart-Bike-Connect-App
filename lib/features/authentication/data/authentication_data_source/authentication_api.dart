

import 'package:dio/dio.dart';

abstract class Authentication{

  Future<Response> generateOtp({required String pathParam , required Map<String, dynamic> body});

  Future<Response> validateOtp({required String pathParam , required Map<String, dynamic> body});

  Future<Response> createPin({required String pathParam ,required Map<String, dynamic> body});

  Future<Response> getUserData({required String pathParam , required Map<String, dynamic> body});

}