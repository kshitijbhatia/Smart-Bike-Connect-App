import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/authentication/data/authentication_data_source/authentication_api_impl.dart';
import 'package:smartbike_flutter/features/authentication/domain/authentication_entity/authentication_model.dart';
import 'package:smartbike_flutter/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/users_list_model.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/main.dart';
import 'package:smartbike_flutter/network/api_end_points.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

final authenticationRepoProvider = Provider<AuthenticationRepo>((ref) => AuthenticationRepo(ref));

class AuthenticationRepo {
  final Ref _ref;
  AuthenticationRepo(this._ref);

  final MethodChannel _platform = MethodChannel(SMARTBIKE_PLUGIN);

  Future<String?> generateOTP({ String? phoneNumber,  String? countryCode , String? email}) async {

    final Response response;
    String transactionId = "";
    Map<String, dynamic> body = {};
    if(phoneNumber != null){
    body = {
        "phone": phoneNumber,
        "appId": "tag-sync",
        "authType": "phone-email",
        "code": countryCode ?? "+91"
      };
    }
    else{
      body = {
        "email": email,
        "appId": "tag-sync",
        "authType": "phone-email",
      };
    }

    try {
      response = await _ref.read(authenticationApiProvider).generateOtp(pathParam: generateOtpEndPoint, body: body);

      var responseData = jsonDecode(response.data);

      if (response.statusCode == 200) {
        List<dynamic> list = responseData['data'];
        Map<String, dynamic> map = list.first;
        transactionId = map["txnId"];
        showToast(LocaleKeys.toastOtpSent.tr());
        return transactionId;
      }
      else if(response.statusCode == 456){
        return transactionId = "no_user_found";
      }
      else if (response.statusCode == 459) {
        if (responseData['message'] == 'OTP has been recently generated for this user.') {
          showToast(LocaleKeys.toastOtpRecent.tr(), warning: true, duration: true);
        } else {
          showToast(LocaleKeys.toastGenericMsg.tr());
        }
      }
      else {
        showToast(LocaleKeys.toastGenericMsg.tr());
      }
    }  catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('generate_OTP_Exc: $e', stackTrace: stacktrace);
        await FirebaseCrashlytics.instance.recordError(e, stacktrace, reason: 'On generate OTP', fatal: true);
        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }
    }
    return null;
  }

  Future <bool?> validateOtp({required String otp, required String txnId}) async {
    final Response response;
    Map<String, dynamic> body = {"token": otp, "txnId": txnId};
    try {
      response = await _ref.read(authenticationApiProvider).validateOtp(pathParam: validateOtpEndPoint, body: body);
      var responseData = jsonDecode(response.data);
      if (response.statusCode == 200) {
        Headers responseHeaders = response.headers;
        if (responseHeaders.map.containsKey('userid')) {
          int userId = int.parse(responseHeaders['userid']!.first);
          AppUtils.setInt(key:Constants.USER_ID, value: userId);
          await createPin();
          await getUserMeta(userIds: [userId]);
        }
        return true;
      }
      else if (response.statusCode == 457) {
        if (responseData['message'] == 'Token could not be validated') {
          // showToast(LocaleKeys.toastOtpMismatch.tr());
          _ref.read(authProvider.notifier).setOtpFormColor(LocaleKeys.keySorry.tr() + LocaleKeys.keyOTPMismatch.tr(),showError: true);
        } else if (responseData['message'] == 'Txn Id sent is invalid or expired') {
          _ref.read(authProvider.notifier).setOtpFormColor(LocaleKeys.keyOTPTimeout.tr(), showError: true);
          // showToast(LocaleKeys.toastOtpExpired.tr());
        } else {
          _ref.read(authProvider.notifier).setOtpFormColor(LocaleKeys.keySorry.tr() + LocaleKeys.keyOTPMismatch.tr(),showError: true);
          // showToast(LocaleKeys.toastOtpFailedValidate.tr());
        }
      }
      else if (response.statusCode == 456) {
        showToast(LocaleKeys.toastOtpValidation.tr());
      }
      else if (response.statusCode == 459) {
        showToast(LocaleKeys.toastOtpRecent.tr());
      }
      else {
        showToast(LocaleKeys.toastTimeOut.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      }
      else {
        log('validate_OTP_Exc: $e', stackTrace: stacktrace);
        await FirebaseCrashlytics.instance.recordError(e, stacktrace, reason: 'On validate OTP', fatal: true);
        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }
    }
    return null;
  }

  Future createPin() async {
    final Response response;
    AuthenticationModel? authenticationModel;
    String? sasToken;
    final deviceUUID = await _platform.invokeMethod(Constants.DEVICE_ID,true);
    Map<String, dynamic> body = {
      "androidId": deviceUUID,
      "userPin": "123456",
    };

    try {
      response = await _ref.read(authenticationApiProvider).createPin(pathParam: createPinEndPoint, body: body);
      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        authenticationModel = AuthenticationModel.fromJson(responseData);
        if (authenticationModel.data.accessToken != '') {

          ///Saving SAS-TOKEN for IoT data upload
          Headers responseHeaders = response.headers;
          if(responseHeaders.map.containsKey('tbx-sas-token')){
            sasToken = responseHeaders['tbx-sas-token']!.first;
            AppUtils.setString(key:Constants.SAS_TOKEN,  value: sasToken);
          }

          AppUtils.setBool(key:Constants.FIRST_TIME_INSTALL,  value: false);
          String accessToken = authenticationModel.data.accessToken;
          String refreshToken = authenticationModel.data.refreshToken;
          ///Saving auth tokens
          AppUtils.setString(key:Constants.ACCESS_TOKEN,  value: accessToken);
          AppUtils.setString(key:Constants.REFRESH_TOKEN,  value: refreshToken);

          ///Formulating userPermMapping
          bool isSuperAdmin = authenticationModel.data.isSystemCreated;
          AppUtils.setBool(key: Constants.SUPER_ADMIN, value: isSuperAdmin);
          UserPermMapping? userPermMapping = authenticationModel.data.userPermMapping.firstWhereOrNull((element) => element.name.toLowerCase() == 'smart-bike'.toLowerCase());
          if(userPermMapping != null){
            List<EdAccess> assignedAccess = userPermMapping.assignedAccess;
            for(final EdAccess edAccess in assignedAccess){

              switch(edAccess){

                case EdAccess.DEALER_ADMIN:
                  await AppUtils.setBool(key: Constants.DEALERSHIP_ADMIN, value: true);
                  break;
                case EdAccess.DEALER_USER:
                  await AppUtils.setBool(key: Constants.DEALERSHIP_USER, value: true);
                  break;
                case EdAccess.PRIMARY_USER:
                  await AppUtils.setBool(key: Constants.PRIMARY_USER, value: true);
                  break;
                case EdAccess.SECONDARY_USER:
                  await AppUtils.setBool(key: Constants.SECONDARY_USER, value: true);
                  break;
              }
            }
            log('extractedUserPermMapping $isSuperAdmin ${userPermMapping} ${assignedAccess.length}');
          }
        }
      }else{

        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        await FirebaseCrashlytics.instance.recordError(e, stacktrace, reason: 'On Create Pin', fatal: true);
        log('create_Pin_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }
    }
  }


  Future getUserMeta({required List<int>  userIds})  async {
    Map<String, dynamic> body = {
      "filters": {
        "userId": userIds
      }
    };
    try {
      final response = await _ref.read(authenticationApiProvider).getUserData(pathParam: getUserMetaEndPoint, body: body);
      if(response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        if(responseData != null){
          var  data =  UsersListModel.fromJson(responseData).data;
          if(data.isNotEmpty){
            for(int i = 0 ; i< data.length ; i++){
              int phoneNumber = data[i].userData[0].contactNumber;
              int countryCode = data[i].userData[0].countryCode;
              String email = data[i].userData[0].email;
              String userName = "${data[i].userData[0].firstName} ${data[i].userData[0].lastName}";
              AppUtils.setInt(key: Constants.USER_COUNTRY_CODE, value: countryCode);
              AppUtils.setInt(key: Constants.USER_PHONE_NUMBER, value: phoneNumber);
              AppUtils.setString(key: Constants.USER_EMAIL, value: email);
              AppUtils.setString(key:Constants.USER_NAME,  value: userName);
            }

          }
        }

      }
      else{
        throw DataException.customException(LocaleKeys.toastUnableToLoad.tr());
      }
    }
    catch(e,stacktrace){
      if (e is DataException) {
        rethrow;
      } else {
        log('get_User_Meta_Exc: $e', stackTrace: stacktrace);
        await FirebaseCrashlytics.instance.recordError(e, stacktrace, reason: 'On Get User Meta', fatal: true);
        throw DataException.customException(LocaleKeys.toastUnableToLoad.tr());
      }
    }
  }
}