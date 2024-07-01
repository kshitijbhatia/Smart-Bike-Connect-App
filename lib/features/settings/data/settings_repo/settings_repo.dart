import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/sbm_mapping_model.dart';
import 'package:smartbike_flutter/features/settings/data/settings_data_source/settings_api_impl.dart';
import 'package:smartbike_flutter/features/user_management/domain/user_management_entity/users_list_model.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/network/api_end_points.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

final settingsRepoProvider = Provider<SettingsRepo>((ref) => SettingsRepo(ref));

class SettingsRepo {
  final Ref _ref;
  SettingsRepo(this._ref);


  Future <bool?> logout({bool? noToast}) async {

    final Response response;
    String? refreshToken = '';
    if(await AppUtils.containsKey( key :Constants.REFRESH_TOKEN)){
      refreshToken = await AppUtils.getString(key :Constants.REFRESH_TOKEN);
    }
    try {
      response = await _ref.read(settingsApiProvider).logout(pathParam: '$logoutEndPoint/$refreshToken');
      if (response.statusCode == 200) {
        if(noToast == null){
          showToast(LocaleKeys.toastLogout.tr());
        }
        return true;
      }
      else {
        if(noToast == null){
          showToast(LocaleKeys.toastErrorWhileLogOut.tr(),warning: true);
        }
        return true;
      }
    } on DataException catch (_){
      rethrow;
    } catch (e,stacktrace) {
      log('logout_Exc: $e', stackTrace: stacktrace);
      throw DataException.customException(LocaleKeys.toastErrorWhileLogOut.tr());
    }finally{
      AppUtils.initiateLogout();
    }
  }
/*===================================================delete SBM Vehicle Mapping API ===============================================*/

  Future <bool?> deleteSBMVehicleMapping({required int vehicleId ,required int sbmId}) async {
    Map<String,dynamic> queryParams = {
      'vehicle_id' : vehicleId,
      'sbm_id' : sbmId,
    };
    try {
      final  response = await _ref.read(settingsApiProvider).deleteSBMVehicleMapping(pathParam: deleteSBMVehicleMappingEndPoint, queryParam: queryParams);
      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        if(responseData['data'] != null){
           String? savedBikeMeta = await AppUtils.getString(key: Constants.SELECTED_BIKE_META);
           BikeData bikeData = BikeData.fromJson(json.decode(savedBikeMeta!));
           BikeData updatedBikeData =  bikeData.copyWith(sbmMappings: '[]');
           await  AppUtils.setString(key:Constants.SELECTED_BIKE_META, value : json.encode(updatedBikeData));
          showToast(LocaleKeys.toastSBMDeleted.tr());
          return true;
        }else{
          showToast(LocaleKeys.toastFailToDelete.tr(),warning: true);
          return null;
        }
      }else{
        throw DataException.customException(LocaleKeys.toastFailToDelete.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('delete_SBM_Mapping_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastFailToDelete.tr());
      }

    }
  }

  /*===================================================Update firmware version ===============================================*/
  Future <bool> updateSBMFunctionality({required int sbm_id ,required String firmwareVersion, required bool immobilisation}) async {

    Map<String,dynamic> requestBody = {};

    if(firmwareVersion == ''){
      requestBody = {
        'functionality' : {'immobilisation_enabled' : immobilisation},
        'sbm_id' : sbm_id,
      };
    }else{
      requestBody = {
        'sw_ver' : firmwareVersion,
        'sbm_id' : sbm_id,
      };
    }

    try {

      final  response = await _ref.read(settingsApiProvider).uploadSBMFunctionality(pathParam: uploadSBMFunctionality,body: requestBody);

      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        log('responseSBMUpload : $responseData');

        ///TODO every where this bike meta is getting updated in shared-preferences,
        ///same has to be done in database as well for the same bike
        String? savedBikeMeta = await AppUtils.getString(key: Constants.SELECTED_BIKE_META);
        BikeData bikeData = BikeData.fromJson(json.decode(savedBikeMeta!));
        List<dynamic> jsonList = jsonDecode(bikeData.sbmMappings);
        List<SbmMapping> sbmMapping = jsonList.map((sbmMapping) => SbmMapping.fromJson(sbmMapping)).toList();
        List<SbmMapping> newSbmMapping = [];
        newSbmMapping.addAll(sbmMapping);
        if(firmwareVersion == ''){
          DfuConfig? existingDfuConfig = newSbmMapping[0].functionality!.dfuConfig;
          newSbmMapping[0].functionality = SbmMappingFunctionality(dfuConfig: existingDfuConfig, immobilisationEnabled: immobilisation);
        }else{
          newSbmMapping[0].swVer = firmwareVersion;
        }
        BikeData updatedBikeData = bikeData.copyWith(sbmMappings: json.encode(newSbmMapping));
        await  AppUtils.setString(key:Constants.SELECTED_BIKE_META, value : json.encode(updatedBikeData));
        if(firmwareVersion != ''){
          showToast(LocaleKeys.toastFirmwareVerUploaded.tr(), generic: true);
        }
        return true;
      }else{
        throw DataException.customException(firmwareVersion == '' ? LocaleKeys.toastFailedSmartnessUpload.tr() : LocaleKeys.toastFailedFirmwareVerUpload.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('updateSBMFunctionality_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(firmwareVersion == '' ? LocaleKeys.toastFailedSmartnessUpload.tr() : LocaleKeys.toastFailedFirmwareVerUpload.tr());
      }

    }
  }

/*===================================================get SBM ID API ===============================================*/

  Future <List<SbmMapping>> getSBMId({required String barCode , required int vehicleId}) async {

    List<SbmMapping> sbmMappingList = [];
    Map<String,dynamic> queryParams = {
      'barcode' : barCode,
      'sbm_status': 'on_shelf,keyfob_mapped'
    };

    try {
      final  response = await _ref.read(settingsApiProvider).getSBM(pathParam: getSBMIdEndPoint, queryParam: queryParams);
      log('responseCode ${response.statusCode}');
      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        if(responseData['statusCode'] == 400){
          if(responseData['message'] == "SBM is not in correct status"){
            showToast(LocaleKeys.toastSBMNotCorrectStatus.tr(),warning: true);
            return sbmMappingList;
          }else{
            showToast(LocaleKeys.toastSBMNotFound.tr(),warning: true);
            return sbmMappingList;
          }
        }else if(responseData['data'] != null){

         int sbmId = responseData['data'][0]['sbm_id'];
         String vehicleSbmKeyFobNames = responseData['data'][0]['sbm_barcode'];
         String? func = responseData['data'][0]['functionality'];
         if(func != null){
           Map<String,dynamic> functionality = jsonDecode(func);
           if(functionality.isNotEmpty){
             log('logging_functionality :------  ${functionality['dfu_config']['target_fileName']} || ${functionality['dfu_config']['target_firmware']}');
           }
         }
         ///Mapping SBM to vehicle
         if(await addSBMToVehicle(vehicleId: vehicleId , sbmId: sbmId)){

           ///Fetching SBM Meta mainly to get the encryption key for pairing
           sbmMappingList =  await getSBMMeta(vehicleSbmKeyFobNames);
         }
        return sbmMappingList;
        }
        else{
          showToast(LocaleKeys.toastNoSBM.tr());
          return sbmMappingList;
        }
      }else{
        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }
    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('get_SBM_Id_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastGenericMsg.tr());
      }

    }
  }

/*===================================================add/map new SBM to vehicle===============================================*/

  Future<bool> addSBMToVehicle({required int vehicleId ,required int sbmId}) async {

    List<Map<String, dynamic>> body =
      [
        {
          "vehicle_id": vehicleId,
          "sbm_id": sbmId,
          "start_time": DateTime.now().toUtc().millisecondsSinceEpoch,
        },
      ];

    try {
      final  response = await _ref.read(settingsApiProvider).addSBMToVehicle(pathParam: addSBMVehicleMappingEndPoint, body : body);

      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        if(responseData['statusCode'] == 400){
          if(responseData['message'].toString().contains('not in correct status')){
            showToast(LocaleKeys.toastFailedToAdd.tr(),warning: true);
            return false;
          }
        }
        if(responseData['response'] != null){
          List<dynamic> responseList = responseData['response'];
          Map<String,dynamic> responseMap = responseList.first;
          if(responseMap['success'] == 1){
            showToast(LocaleKeys.toastSBMAdded.tr(), warning: false);
            return true;
          }else if(responseMap['failed'] == 1)
          throw DataException.customException(LocaleKeys.toastFailedToAdd.tr());
        }
        return false;
      }else{
        throw DataException.customException(LocaleKeys.toastFailedToAdd.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('add_SBM_To_Vehicle_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastFailedToAdd.tr());
      }

    }
  }

/*==================================================get all SBM Meta api===============================================*/

  Future <List<SbmMapping>> getSBMMeta(String vehicleSbmKeyFobNames)  async {
    List<SbmMapping> sbmMappingList = [];
    List<BikeData> bikeList = [];
    Map<String, dynamic> body =
    {
      "filters": {"vehicleSbmKeyFobNames":[vehicleSbmKeyFobNames]},
      "sort": [
        {
          "property": "id",
          "direction": "asc"
        }
      ],
      "data_filters": [
      ]

    };
    try {
      final response = await _ref.read(settingsApiProvider).getSBMMeta(pathParam: searchSbmEndPoint, body: body);
      if( response.statusCode == 200){
        if(json.decode(response.data)['data'] != null){
          bikeList = (json.decode(response.data)['data'] as List<dynamic>).map((bike) => BikeData.fromJson(bike)).toList();
          await AppUtils.setString(key: Constants.SELECTED_BIKE_META, value : json.encode(bikeList[0]));
          List<dynamic> jsonList = jsonDecode(bikeList[0].sbmMappings);
          sbmMappingList = jsonList.map((sbmMapping) => SbmMapping.fromJson(sbmMapping)).toList();
          return sbmMappingList;
        }else if(json.decode(response.data)['message'] == 'No records found'){
          throw DataException.customException(LocaleKeys.toastFailedToGetDetails.tr());
        }
        else{
          return sbmMappingList;
        }
      }else{
        throw DataException.customException(LocaleKeys.toastFailedToGetDetails.tr());
      }
    }
    catch(e,stacktrace){
      if (e is DataException) {
        rethrow;
      } else {
        log('get_SBM_Meta_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastFailedToGetDetails.tr());
      }
    }
  }

  /*===================================================edit Bike Name API ===============================================*/

  Future <bool?> editBikeName({required int vehicleId ,required int userId , required String updatedBikeName}) async {
    Map<String,dynamic> queryParams = {
      'vehicle_id' : vehicleId,
      'user_id' : userId,
      'friendly_name' : updatedBikeName,
    };
    try {
      final  response = await _ref.read(settingsApiProvider).editBikeName(pathParam: editBikeNameEndPoint, queryParam: queryParams);
      if( response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        if(responseData['data'] != null){
          String? savedBikeMeta = await AppUtils.getString(key: Constants.SELECTED_BIKE_META);
          BikeData bikeData = BikeData.fromJson(json.decode(savedBikeMeta!));
          BikeData updatedBikeData =  bikeData.copyWith(friendlyName: updatedBikeName,);
          await  AppUtils.setString(key:Constants.SELECTED_BIKE_META, value : json.encode(updatedBikeData));
          showToast(LocaleKeys.toastBikeNameUpdated.tr());
          return true;
        }else{
          return null;
        }
      }else{
        throw DataException.customException(LocaleKeys.toastEditBikeNameFailed.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('edit_bike_name_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastEditBikeNameFailed.tr());
      }

    }
  }
  /*===================================================edit Profile Api===============================================*/

  Future <bool?> editProfile({required String phoneNumber ,required String name , required String email, required int countryCode,required int userId}) async {
    Map<String, dynamic> body =
      {
        "first_name": name,
        "last_name": "",
        "email_id": email,
        "code": countryCode,
        "phone": phoneNumber,
        "user_id": userId
    };
    try {
      final  response = await _ref.read(settingsApiProvider).editProfile(pathParam: editProfileEndPoint, body : body);
      var responseData = jsonDecode(response.data);
      if( response.statusCode == 200){
        await getUserMeta();
        showToast(LocaleKeys.toastProfileUpdated.tr());
        return true;
      }else if(responseData['statusCode'] == 902){
        return false;
      }else if(responseData['statusCode'] == 1012){
        throw DataException.customException(LocaleKeys.toastUpdateAtLeastOneFiled.tr());
      }else{
        throw DataException.customException(LocaleKeys.toastEditProfileFailed.tr());
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('edit_profile_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastEditProfileFailed.tr());
      }

    }
  }
  /*===================================================edit Bike Name API ===============================================*/

  Future getUserMeta()  async {
    int? userIds = await AppUtils.getInt(key:Constants.USER_ID);
    Map<String, dynamic> body = {
      "filters": {
        "userId": [userIds]
      }
    };

    try {
      final response = await _ref.read(settingsApiProvider).getUserData(pathParam: getUserMetaEndPoint, body: body);
      if(response.statusCode == 200){
        var responseData = jsonDecode(response.data);
        if(responseData != null){
          var  data =  UsersListModel.fromJson(responseData).data;
          if(data.isNotEmpty){
            for(int i = 0 ; i< data.length ; i++){
              int phoneNumber = data[i].userData[0].contactNumber;
              int countryCode = data[i].userData[0].countryCode;
              String email = data[i].userData[0].email;
              String userName = "${data[i].userData[0].firstName}";
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
        throw DataException.customException(LocaleKeys.toastUnableToLoad.tr());
      }
    }
  }

  Future<bool> downloadZIP({required String fileName, required String filePath}) async{

    try {

      final  response = await _ref.read(settingsApiProvider).downloadZIPFile(fileName: fileName,toSavePath: filePath);

      if(response){
        showToast(LocaleKeys.toastZIPFileDownloaded.tr(),warning: false);
        return true;
      }else{
        return false;
      }

    } catch (e,stacktrace) {
      if (e is DataException) {
        rethrow;
      } else {
        log('download_ZIP_Exc: $e', stackTrace: stacktrace);
        throw DataException.customException(LocaleKeys.toastZIPDownloadFailed.tr());
      }

    }

  }

}