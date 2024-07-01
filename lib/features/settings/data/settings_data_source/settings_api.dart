

import 'package:dio/dio.dart';

abstract class Settings{

  Future<Response> logout({required String pathParam , Map<String, dynamic> body});

  Future<Response> uploadSBMFunctionality({required String pathParam , required Map<String, dynamic> body});

  Future<bool> downloadZIPFile({required String fileName,required String toSavePath});

  Future<Response> deleteSBMVehicleMapping({required String pathParam , required Map<String, dynamic> queryParam});

  Future<Response> getSBM({required String pathParam , required Map<String, dynamic> queryParam});

  Future<Response> addSBMToVehicle({required String pathParam ,required  List<Map<String, dynamic>> body});

  Future<Response> getSBMMeta({required String pathParam , required Map<String, dynamic> body});

  Future<Response> editProfile({required String pathParam , required Map<String, dynamic> body});

  Future<Response> editBikeName({required String pathParam , required Map<String, dynamic> queryParam});

  Future<Response> getUserData({required String pathParam , required Map<String, dynamic> body});
}