import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/sbm_mapping_model.dart';
import 'package:smartbike_flutter/features/service/app_service.dart';
import 'package:smartbike_flutter/features/settings/domain/setting_entity/state/setting_state.dart';
import 'package:smartbike_flutter/main.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

import '../../../../app_utils/app_utils.dart';
import '../../../../constants/strings.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bikes/domain/bike_entity/bike_model/bike_model.dart';


final settingController = StateNotifierProvider<SettingController, SettingState>((ref) => SettingController(ref));

class SettingController extends StateNotifier<SettingState> {

  final Ref ref;
  BikeData? bikeData;
  final _platform = const MethodChannel(SMARTBIKE_PLUGIN);
  SettingController(this.ref) : super(SettingState());

   Future<List<SbmMapping>> initializeBikeData() async{
    String? savedBikeMeta = await AppUtils.getString(key: Constants.SELECTED_BIKE_META);
    bikeData = BikeData.fromJson(json.decode(savedBikeMeta!));
    List<dynamic> jsonList = jsonDecode(this.bikeData!.sbmMappings);
    return jsonList.map((sbmMapping) => SbmMapping.fromJson(sbmMapping)).toList();
  }

  setLanguageText(final String languageState) {
    state = state.copyWith(languageText: languageState);
  }

  setDefaultViewIndex(final int selectedIndex) {
    state = state.copyWith(selectedIndex: selectedIndex);
  }

  setFirmwareVersion(String firmwareVersionReceived){
    state = state.copyWith(firmwareVersion: firmwareVersionReceived);
  }

  setSmartnessValue(final int smartnessValueState) {
    state = state.copyWith(smartnessValue: smartnessValueState);
  }

  setSmartnessColor(final bool smartnessColorState) {
    state = state.copyWith(smartnessColor: smartnessColorState);
  }

  setSendLearnModeLoader(final bool sendLearnModeState) {
    state = state.copyWith(isSendLearnModeLoader: sendLearnModeState);
  }

  setUserName(final String userName) {
    state = state.copyWith(userName: userName);
  }

  setUserEmail(final String email) {
    state = state.copyWith(email: email);
  }

  setPhoneNumber(final int phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  setCountryCode(final int countryCode) {
    state = state.copyWith(countryCode: countryCode);
  }

  setRoleText(final String roleName) {
    state = state.copyWith(roleName: roleName);
  }

  setProfileUpdateErrorBox(final bool errorBox) {
    state = state.copyWith(profileUpdateErrorBox: errorBox);
  }

  setDFUButtonVisibility(final bool visibilityStatus){
    state = state.copyWith(dfuButtonVisibility: visibilityStatus);
  }
  
  dfuProgressLoader(int? percentage){
    state = state.copyWith(dfuProgressPercentage: percentage);
  }

  updateSettingsDataOfSBM(List<SbmMapping> sbmMapping) async{

    if(sbmMapping[0].functionality != null){
      if(sbmMapping[0].functionality!.immobilisationEnabled!){
        setSmartnessValue(1);
      }else{
        setSmartnessValue(0);
      }
    }
  }

  updateSmartnessOnSBM() async{

    final smartnessValue = ref.read(settingController.select((value) => value.smartnessValue));
    String SMARTNESS = Constants.SMARTNESS_ENABLE_TEXT;
    if(smartnessValue == 1){
      SMARTNESS = Constants.SMARTNESS_ENABLE_TEXT;
    }else{
      SMARTNESS = Constants.SMARTNESS_DISABLE_TEXT;
    }

    Map<String,dynamic> smartnessRequestBody = {
      'SmartnessValue' : SMARTNESS,
      'isSmartnessCallbackRequired' : false
    };

    bool status = await _platform.invokeMethod(Constants.CHANGE_SMARTNESS, smartnessRequestBody);
    if(!status){
      showToast(LocaleKeys.toastNotifySmartnessFailed.tr(),warning: true,duration: true);
      return;
    }
  }

  clearSettingsData(){
    setSendLearnModeLoader(false);
    setSmartnessColor(false);
    setSmartnessValue(1);
    setFirmwareVersion('');
    setDFUButtonVisibility(false);
    dfuProgressLoader(null);
  }


  Future<bool?> uploadFirmwareVersion(String firmwareVersion) async{

    try {

      List<SbmMapping> sbmMappingList = await initializeBikeData();

        ///If firmware-version is same as present on backend, API call will be skipped
        bool? response = null;
        if(sbmMappingList[0].swVer!.toUpperCase() != firmwareVersion.toUpperCase()){
          response = await ref.read(applicationService).uploadFirmwareVersion(sbmId: sbmMappingList[0].id!, firmwareVersion: firmwareVersion);
        }

        if(sbmMappingList[0].functionality != null && sbmMappingList[0].functionality!.dfuConfig != null){
          if(sbmMappingList[0].functionality!.dfuConfig!.targetFirmware.toUpperCase() != firmwareVersion){
            log('firmware_update_required');
            setDFUButtonVisibility(true);
          }
        }

        // Tuple<String, bool> file = await AppUtils.getFilePath(fileName: 'tag_dfu_app_v3.I.3_TVSASEAN.zip');
        // await AppUtils.deleteFile(file.item1);
        return response;

    } catch (e,stacktrace) {
      log(e.toString(),stackTrace: stacktrace);
      showToast(e.toString(), warning: true, duration: true);
      return false;
    }
  }

  Future<bool> uploadSmartness({required int sbmId,required bool immobilisation}) async{

    try {

      bool response = await ref.read(applicationService).uploadSmartnessValue(sbmId: sbmId,immobilisation: immobilisation);
      return response;

    } catch (e,stacktrace) {
      log(e.toString(),stackTrace: stacktrace);
      showToast(e.toString(), warning: true, duration: true);
      return false;
    }
  }



  Future<bool> downloadZIP({required String fileName, required String filePath}) async{

     try{

         bool downloadZipResponse = await ref.read(applicationService).downloadZIPFile(fileName: fileName,filePath: filePath);
         return downloadZipResponse;

       //   log('zipFileAlreadyExists-No_need_to_download');
       //   await AppUtils.deleteFile(await AppUtils.getFilePath(fileName: fileName));

     }catch(e,stacktrace){
       log(e.toString(),stackTrace: stacktrace,);
       showToast(e.toString(), warning: true, duration: true);
       return false;
     }
  }


  /*========================================= Logout ===================================*/
  Future <bool?> logout() async {
    try {
      bool? response = await ref.read(applicationService).logout();
      return response;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return false;
    }
  }

  /*========================================delete SBM Vehicle Mapping===================================*/

  Future <bool?> deleteSBMVehicleMapping({required int vehicleId, required int sbmId}) async {
    try {
      bool? response = await ref.read(applicationService)
          .deleteSBMVehicleMapping(vehicleId: vehicleId, sbmId: sbmId);
      return response;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return false;
    }
  }

  /*======================================== get SBM ==================================*/

  Future<List<SbmMapping>> getSBMId({required String barCode, required int vehicleId}) async {
    List<SbmMapping> response = [];
    try {
      response = await ref.read(applicationService).getSBMId(barCode: barCode, vehicleId: vehicleId);
      return response;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return response;
    }
  }

/*=======================================edit profile==================================*/

  Future <bool?> editProfile({required String name, required String email, required String phoneNumber, required int countryCode, required int userId }) async {
    bool? response;
    try {
      response = await ref.read(applicationService).editProfile(name: name, email: email, phoneNumber: phoneNumber, countryCode: countryCode, userId: userId);
      if(response == true){
        setProfileUpdateErrorBox(false);
        return true;
      }else if(response == false){
        setProfileUpdateErrorBox(true);
        return false;
      }
      else{
        setProfileUpdateErrorBox(false);
        return null;
      }
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      setProfileUpdateErrorBox(false);
      return response;
    }
  }

/*=======================================edit bike name==================================*/

  Future <bool?> editBikeName({required int vehicleId, required int userId, required String updatedBikeName}) async {
    try {
    bool?  response = await ref.read(applicationService).editBikeName(vehicleId: vehicleId , userId: userId ,updatedBikeName: updatedBikeName);
      return response;
    } catch (e) {
      showToast(e.toString(), warning: true, duration: true);
      return false;
    }
  }
}
/*===========================================for change the locale======================================*/


final localeNotifierProvider = StateNotifierProvider((ref) => LocaleController());

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en'));
  setLocale({locale})  async {
    await EasyLocalization.of(navigatorKey.currentState!.context)!.setLocale(locale);
    state = locale!;
  }
}