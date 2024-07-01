

import 'package:dio/dio.dart';

abstract class MyBike{

  Future<Response> getBike({required String pathParam , required Map<String, dynamic> body,required  Map<String, dynamic> headers});

  Future<Response> searchSBM({required String pathParam , required Map<String, dynamic> body});

}