
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/features/user_management/data/user_management_data_source/user_management_api.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/network/network_provider.dart';

final UserManagementApiProvider = Provider<UserManagement>((ref) => UserManagementImpl(ref));

class UserManagementImpl implements UserManagement{

  final Ref _ref;

  UserManagementImpl(this._ref);



  @override
  Future<Response> getUsers({required String pathParam, required Map<String, dynamic> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_get_users $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> searchUser({required String pathParam, required Map<String, dynamic>? body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_search_user $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> createUser({required String pathParam, required Map<String, dynamic> body, required Map<String, dynamic> queryParam}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body ,queryParameters: queryParam );
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_create_user $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> deleteUserMapping({required String pathParam, required Map<String, dynamic> queryParam}) async {
    try {
      final response = await _ref.read(clientProvider).delete( pathParam ,queryParameters: queryParam );
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_delete $error');
      throw DataException.fromDioError(error);
    }
  }

  @override
  Future<Response> vehicleUserMapping({required String pathParam, required List<Map<String, dynamic>> body}) async {
    try {
      final response = await _ref.read(clientProvider).post( pathParam ,data: body ,);
      return response;
    } on DioError catch (error) {
      debugPrint('******exc_vehicle_user_mapping $error');
      throw DataException.fromDioError(error);
    }
  }



}