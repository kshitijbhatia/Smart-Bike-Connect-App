
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/constants/strings.dart';

import 'interceptor.dart';

final clientProvider = Provider((ref) => Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    baseUrl: Constants.prodUrlCompName['url']!))
  ..interceptors.add(DioInterceptor())
  ..interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
  ))
);

