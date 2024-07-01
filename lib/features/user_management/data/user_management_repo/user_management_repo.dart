import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/user_management/data/user_management_data_source/user_management_api_impl.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/search_user_model.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/users_list_model.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/network/api_end_points.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

final usersRepoProvider = Provider<UserManagementRepo>((ref) => UserManagementRepo(ref));

class UserManagementRepo {

  final Ref _ref;

  UserManagementRepo(this._ref);


  Future <List<Users>> getAllUsers({ required List<int>  userIds})  async {
    Map<String, dynamic> body = {
        "filters": {
          "userId": userIds
        }
    };
    try {
      final response = await _ref.read(UserManagementApiProvider).getUsers(pathParam: usersListEndPoint, body: body);
      if(response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        var data =  UsersListModel.fromJson(responseData).data;
        return data;
      }
      else{
        throw DataException.customException(LocaleKeys.toastUnableLoadUser.tr());
      }
    }
    catch(e,stacktrace){
      if (e is DataException) {
        rethrow;
      } else {
        log('get_All_Users_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastUnableLoadUser.tr());
      }
    }
  }


  Future <List<SearchData>> searchUser({required String phoneNumber ,required String countryCode }) async {

    Map<String, dynamic> body = {
      "phoneNumber": phoneNumber,
      "countryCode" : countryCode
    };
    try {
      final  response = await _ref.read(UserManagementApiProvider).searchUser(pathParam: searchUserEndPoint, body: body);
      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        var data =  SearchUserModel.fromJson(responseData).data;
        return data;
      }else if(response.data != null){
        var responseData = jsonDecode(response.data);
        if(responseData['message'] == 'No user found with given phone number'){
          return [];
        }else{
          throw DataException.customException(LocaleKeys.toastFailedSearchUser.tr());
        }
      }else{
        throw DataException.customException(LocaleKeys.toastFailedSearchUser.tr());
      }

    }catch (e,stacktrace) {
      if(e is DataException){
        rethrow;
      }
      log('search_User_Exc: $e', stackTrace: stacktrace);
      throw DataException.customException(LocaleKeys.toastFailedSearchUser.tr());

    }
  }

  Future <int?> createUser({required String phoneNumber , required String countryCode ,required String userName, required String email,required bool isPrimary}) async {
    String modifyUsername = '' ;
    if(email.contains("@") || email.contains(".") ){
      modifyUsername = email.replaceAll('.', '_').replaceAll('@', '_');
      log("modifyUsername $modifyUsername");
    }

    Map<String, dynamic> body = {
        "userData": {
          "phoneNumber": phoneNumber,
          "countryCode": countryCode,
          "username": modifyUsername,
          "email": email,
          "password": "${userName}SBM123",
          "firstName": userName,
          "lastName": "",
          "userTypeId": 1
        },
        "userRole": isPrimary ? "primary-user" : "secondary-user"

    };
    Map<String,dynamic> queryParams = {
      'company' : Constants.prodUrlCompName['companyName']!,
    };
    try {
      final  response = await _ref.read(UserManagementApiProvider).createUser(pathParam: createUserEndPoint, body: body, queryParam: queryParams);
      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        int? userId = responseData['uuid'];
        return userId;
      }else{
        throw DataException.customException(LocaleKeys.toastUnableCreateUser.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('create_User_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastUnableCreateUser.tr());
      }

    }
  }

  Future <bool> vehicleUserMapping({required int vehicleId , required String userType ,required int userId, required String name}) async {

    List<Map<String, dynamic>> body =
      [
        {
          "vehicle_id": vehicleId,
          "user_type": userType,
          "user_id" : userId,
          "functionality": {
            "username": name
          }
        }
      ];

    try {
      final  response = await _ref.read(UserManagementApiProvider).vehicleUserMapping(pathParam: vehicleUserMappingEndPoint, body: body);
      if( response.statusCode == 200){
       showToast(LocaleKeys.toastRecordInsert.tr());
        return true;
      }else{
        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('vehicle_User_Mapping_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }

    }
  }

  Future <int?> deleteUserMapping({required int vehicleId ,required int userId,}) async {

    Map<String,dynamic> queryParams = {
      'vehicle_id' : vehicleId,
      'user_id' : userId,
    };
    try {
      final  response = await _ref.read(UserManagementApiProvider).deleteUserMapping(pathParam: deleteUserMappingEndPoint, queryParam: queryParams);
      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        if(responseData['data'] != null){
          List data = responseData['data'];
          int? userId = data.first['user_id'];
          showToast(LocaleKeys.toastRecordDelete.tr());
          return userId;
        }else{
          return null;
        }

      }else{
        throw DataException.customException(LocaleKeys.toastFailedDeleteUser.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('delete_User_Mapping_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastFailedDeleteUser.tr());
      }

    }
  }
}