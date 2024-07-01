
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/sbm_mapping_model.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import '../generated/locale_keys.g.dart';
import '../main.dart';
import '../smartbike_database/smartbike_db_repo.dart';
import '../widgets/toast.dart';


class AppUtils{

  static SharedPreferences? _sharedPreferences;
  static const MethodChannel _channelSmartBike = MethodChannel(SMARTBIKE_PLUGIN);

  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }else{
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }catch(e){
      return false;
    }
  }

  static String calculateTimeDifference(int startTime, int endTime) {
    Duration difference = DateTime.fromMillisecondsSinceEpoch(startTime)
        .difference(DateTime.fromMillisecondsSinceEpoch(endTime));

    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static Future<Map<String, dynamic>> getStartServiceRequestBody() async{
    String? sasToken = await AppUtils.getString(key: Constants.SAS_TOKEN);
    int? phoneNumber =   await AppUtils.getInt(key:Constants.USER_PHONE_NUMBER);
    Map<String,dynamic> startServiceRequestBody = {
      "sasToken" : sasToken,
      "mobileNumber" : phoneNumber
    };
    log('startServiceReqBody $startServiceRequestBody');
    return startServiceRequestBody;
  }

  ///In iOS macId is not revealed by CoreBluetooth library
  ///So we send the user_assigned macId's from here.
  static void sendWhiteListToiOS(SmartBikeDatabaseRepo dbRepo) async{

    if(Platform.isIOS){

      List<BikeData> bikeDataList = await dbRepo.getAllBikes();

      List<String> _whiteList = [];

      for(BikeData bikeData in bikeDataList){

        List<dynamic> jsonList = jsonDecode(bikeData.sbmMappings);
        List<SbmMapping> _sbmMappingList = jsonList.map((sbmMapping) => SbmMapping.fromJson(sbmMapping)).toList();

        if(_sbmMappingList.isNotEmpty){
          _whiteList.add(_sbmMappingList[0].macAddress!);
        }
      }

      ///Testing sensors
      // _whiteList.add('C6:BE:E4:74:98:9C');
      // _whiteList.add('C8:A7:FB:53:28:68');
      // _whiteList.add('DA:4C:6D:64:0E:A8');
      // _whiteList.add('D6:94:3E:2E:6B:71');

      await _channelSmartBike.invokeMethod(Constants.SEND_WHITELIST, _whiteList);
    }
  }

  static Future<Tuple<String, bool>> getFilePath({required String fileName}) async{

    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/$fileName';
    File file = File('$path');

    if(await file.exists()){
      return Tuple(path, true);
    }

    return Tuple(path, false);
  }


  static deleteFile(String fileName) async{
    File file = File('$fileName');
    if(await file.exists()){
      log('AppUtils_filePath ${file.path}');
      await file.delete();
    }else{
      log('zip_does_not_exists');
    }
  }

  static initiateLogout() async{
    await AppUtils.removePref();
    await _channelSmartBike.invokeMethod(Constants.STOP_SERVICES, true);
  }

  static UserSessionExpired() async{
    await AppUtils.initiateLogout();
    showToast(LocaleKeys.toastSessionExpired.tr());
    Navigator.pushAndRemoveUntil(navigatorKey.currentState!.context, MaterialPageRoute(builder: (context) =>  LoginScreen()), (Route<dynamic> route) => false);
  }

 static Future <void> setString({required String key, required String value}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences!.setString(key,value );
 }

  static Future <String?> getString({required String key}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
   return  _sharedPreferences!.getString(key);
 }

  static Future <void> setInt({required String key, required int value}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
   await _sharedPreferences!.setInt(key,value );
 }


  static Future <int?> getInt({required String key}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
   return  _sharedPreferences!.getInt(key);
 }

  static Future <void> setBool({required String key, required bool value}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences!.setBool(key,value );
 }


  static Future <bool?> getBool({required String key}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
   return  _sharedPreferences!.getBool(key);
 }

  static Future <void> setStringList({required String key, required List<String>  value}) async{
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences!.setStringList(key,value );
  }


  static Future <List<String>?> getStringList({required String key}) async{
    _sharedPreferences = await SharedPreferences.getInstance();
    return  _sharedPreferences!.getStringList(key);
  }


  static  Future <void> removePref() async{
   _sharedPreferences = await SharedPreferences.getInstance();
   await AppUtils.removeKey(key: Constants.USER_EMAIL);
   await AppUtils.removeKey(key: Constants.USER_NAME);
   await AppUtils.removeKey(key: Constants.USER_PHONE_NUMBER);
   await AppUtils.removeKey(key: Constants.USER_COUNTRY_CODE);
   await AppUtils.removeKey(key: Constants.ACCESS_TOKEN);
   await AppUtils.removeKey(key: Constants.REFRESH_TOKEN);
   await AppUtils.removeKey(key: Constants.USER_ID);
   await AppUtils.removeKey(key: Constants.SAS_TOKEN);
   await AppUtils.removeKey(key: Constants.USER_EMAIL);
   await AppUtils.removeKey(key: Constants.SELECTED_BIKE_META);
   await AppUtils.removeKey(key: Constants.FIRST_TIME_INSTALL);
   await AppUtils.removeKey(key: Constants.ROLE);

   await AppUtils.removeKey(key: Constants.SUPER_ADMIN);
   await AppUtils.removeKey(key: Constants.DEALERSHIP_ADMIN);
   await AppUtils.removeKey(key: Constants.DEALERSHIP_USER);
   await AppUtils.removeKey(key: Constants.PRIMARY_USER);
   await AppUtils.removeKey(key: Constants.SECONDARY_USER);
 }

  static Future <void> removeKey({required String key}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
   _sharedPreferences!.remove(key);
 }

  static Future <bool> containsKey({required String key}) async{
   _sharedPreferences = await SharedPreferences.getInstance();
   return  _sharedPreferences!.containsKey(key);
 }

}