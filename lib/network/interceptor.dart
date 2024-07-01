import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/strings.dart';


class DioInterceptor extends Interceptor {


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {


    log("Request[${options.method}] => PATH: ${options.path}");

    log(options.baseUrl + options.path);
    options.headers['Content-type'] = 'application/json';
    options.headers['tenantId'] = Constants.prodUrlCompName['companyName']!;
    if(await AppUtils.containsKey( key :Constants.ACCESS_TOKEN)){
      String? accessToken = await AppUtils.getString(key :Constants.ACCESS_TOKEN);
      options.headers['Authorization'] = 'Bearer $accessToken';
      //String? refreshToken = await AppUtils.getString(key :Constants.REFRESH_TOKEN);
      //log('refreshToken*** $refreshToken');
    }
    if(await AppUtils.containsKey( key :Constants.USER_ID)){
      int? userId = await  AppUtils.getInt(key:Constants.USER_ID);
      options.headers['userId'] = '$userId';
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("Response Status Code: [${response.statusCode}]");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async{
    log("Error[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");

    if(err.response != null && err.response!.statusCode == 401){
      String? newAccessToken = await fetchNewAccessToken(err.requestOptions);
      if(newAccessToken == null){
        return handler.resolve(err.response!);
      }else{
        return handler.resolve(await _retry(err.requestOptions));
      }
    }else if(err.type == DioErrorType.badResponse){
      log('badResponse ${err.response}');
      return handler.resolve(err.response!);
    }
    super.onError(err, handler);
  }

  final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), baseUrl: Constants.prodUrlCompName['url']!));


  Future<String?> fetchNewAccessToken(RequestOptions requestOptions) async{

    if(await AppUtils.checkInternetConnection()){

      try{

        String? refreshToken = await AppUtils.getString(key :Constants.REFRESH_TOKEN);

        final response = await dio.get('refresh/$refreshToken');

        log('refreshToken_Url : ${response.requestOptions.baseUrl}${response.requestOptions.path}');

        if(response.statusCode == 200 || response.statusCode == 201){


          final responseData = response.data;
          int statusCode = responseData['status'];
          log('new_accessToken ${response.statusCode} | $statusCode');

          if(statusCode == 200){
            Map<String,dynamic> tokens = responseData['data'];
            String accessToken = tokens['accessToken'];
            String refreshToken = tokens['refreshToken'];
            AppUtils.setString(key: Constants.ACCESS_TOKEN, value :accessToken);
            AppUtils.setString(key:Constants.REFRESH_TOKEN, value :refreshToken);
            requestOptions.headers['Authorization'] = 'Bearer $accessToken';
            return accessToken;
          }else if(statusCode == 401){
            AppUtils.UserSessionExpired();
            return null;
          }
        }
      }catch(e){
        log('refreshTokenApiCallExc ${e.toString()}');
        AppUtils.UserSessionExpired();
      }
    }else{
      AppUtils.UserSessionExpired();
    }
    return null;
  }



  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

}




