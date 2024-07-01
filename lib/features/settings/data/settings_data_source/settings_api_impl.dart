import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/features/settings/data/settings_data_source/settings_api.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/network/network_provider.dart';


final settingsApiProvider = Provider<Settings>((ref) => SettingsImpl(ref));

class SettingsImpl implements Settings{

  final Ref _ref;

  SettingsImpl(this._ref);

  @override
  Future<Response> logout({required String pathParam, Map<String, dynamic>? body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_log_out $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> uploadSBMFunctionality({required String pathParam, required Map<String, dynamic> body}) async{
    try {
      final response = await _ref.read(clientProvider).put( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_uploadSBMFunc $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> deleteSBMVehicleMapping({required String pathParam, required  Map<String, dynamic> queryParam}) async {
    try {
      final response = await _ref.read(clientProvider).delete( pathParam ,queryParameters: queryParam);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_delete_SBM_Vehicle_Mapping $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> addSBMToVehicle({required String pathParam, required List<Map<String, dynamic>> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_add_SBM_To_Vehicle $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> getSBM({required String pathParam, required Map<String, dynamic> queryParam}) async {
    try {
      final response = await _ref.read(clientProvider).get( pathParam ,queryParameters: queryParam);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_get_SBM $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> getSBMMeta({required String pathParam, required Map<String, dynamic> body}) async {
    try {
      final response = await _ref.read(clientProvider).post(
          pathParam, data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_get_SBM_meta $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> editProfile({required String pathParam, required Map<String, dynamic> body}) async{
    try {
      final response = await _ref.read(clientProvider).post(pathParam, data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_edit_profile $error');
      throw DataException.fromDioError(error);

  }
  }

  @override
  Future<Response> editBikeName({required String pathParam, required Map<String, dynamic> queryParam}) async {
    try {
      final response = await _ref.read(clientProvider).post(
          pathParam, queryParameters: queryParam);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_bike_name $error');
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

  @override
  Future<bool> downloadZIPFile({required String fileName, required String toSavePath}) async{

    try {
      String downloadZipUri = 'http://api.tagbox.co/restservice/v1/d2c/android/app?fwName=';
      final dio = Dio(BaseOptions(
          connectTimeout: const Duration(minutes: 2), baseUrl: downloadZipUri));

      String progress = '0';
      log('downloadZipUrl : $downloadZipUri$fileName');

      var response = await dio.download(
        '$downloadZipUri$fileName',
        toSavePath,
        onReceiveProgress: (rcv, total) {

          // setState(() {
          progress = ((rcv / total) * 100).toStringAsFixed(0);
          print('downloadZipProgress : $progress');

          // });
          //
          // if (progress == '100') {
          //   setState(() {
          //     isDownloaded = true;
          //   });
          // } else if (double.parse(progress) < 100) {}

        },
        deleteOnError: true,
      );

      log('downloadZipFileResponse ${response.statusCode} ${response.statusMessage}');
      if (progress == '100' || double.parse(progress) < 100) {
        return true;
      } else {
        return false;
      }
    }on DioError catch (error) {
      debugPrint('******downloadZipFile_Exc $error');
      throw DataException.fromDioError(error);
    }
  }
}