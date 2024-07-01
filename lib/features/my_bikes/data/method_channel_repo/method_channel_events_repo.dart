

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/data/method_channel_events/method_channel_service.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/my_bike_controller.dart';

import '../../../../app_utils/app_utils.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../settings/presentation/controllers/setting_controller.dart';

class MethodChannelEventHandler implements MethodChannelService{

  late MyBikeNativeControllerClass _myBikeNativeControllerClass;
  late SettingController _settingController;
  final Ref _ref;

   MethodChannelEventHandler(this._ref){
      _myBikeNativeControllerClass = _ref.read(myBikeNativeController.notifier);
      _settingController = _ref.read(settingController.notifier);
  }

  @override
  void onBleStateChange(bool newState) {
    _myBikeNativeControllerClass.notifyBleStatus(newState);
    _myBikeNativeControllerClass.setFailedToAdvertiseWarning(false);
  }

  @override
  void onBikeVicinityChange(final String value) {
    _myBikeNativeControllerClass.bikeVicinityStatusState(value);
  }

  @override
  void onButtonStateChange(final String value) {
    _myBikeNativeControllerClass.bikeButtonStatus(value);
  }

  @override
  void onBikeStateChange(String newBikeState) {

     switch(newBikeState){

       case 'BIKE_WILL_LOCK_AT_IGNITION_OF' :
         _myBikeNativeControllerClass.bikeStateUpdate(LocaleKeys.keyTurnedOff.tr());
         break;

       case 'MOVE_CLOSER_TO_BIKE' :
         _myBikeNativeControllerClass.bikeStateUpdate(LocaleKeys.keyBikeNotInVicinity.tr());
         break;

       default:
         _myBikeNativeControllerClass.bikeStateUpdate('');
         break;
     }
  }

  @override
  void onLastParkedLocationChange(value) {
    _myBikeNativeControllerClass.lastParkedLocationState(value);
  }

  @override
  void onSBMConnected() {
    _myBikeNativeControllerClass.sbmStatusState(SBM_STATE.CONNECTED);
    _myBikeNativeControllerClass.setFailedToAdvertiseWarning(false);
    _settingController.updateSmartnessOnSBM();
  }

  @override
  void onSBMDisconnected() {
    _myBikeNativeControllerClass.sbmStatusState(SBM_STATE.DISCONNECTED);
    _myBikeNativeControllerClass.bikeStateUpdate('');
  }

  @override
  void onSendLearnModeChange(bool result) {
    _myBikeNativeControllerClass.sendLearnMode(result);
  }

  @override
  void onSmartnessChange(String result) {
    _myBikeNativeControllerClass.smartnessChanged(result);
  }

  @override
  void onFirmwareVersionReceived(String firmwareVersion) {
    _settingController.setFirmwareVersion(firmwareVersion);
    _settingController.uploadFirmwareVersion(firmwareVersion);
    log('firmwareVersion $firmwareVersion');
  }


  @override
  void onFailedToAdvertise(bool warningState) {
    _myBikeNativeControllerClass.setFailedToAdvertiseWarning(warningState);
  }

  @override
  void onDfuProgress(int percentage) {
     _settingController.dfuProgressLoader(percentage);
  }


  @override
  void onSasTokenExpired() async{

     //TODO this has to be confirmed whether this logout tokes api will be called or not.
    // try {
    //   final response = await _ref.read(settingsRepoProvider).logout(noToast: true);
    //   log('logout_response $response');
    // } catch (e,stacktrace) {
    //   log('sasTokenExc $e',stackTrace: stacktrace);
    // }finally{
    //   AppUtils.UserSessionExpired();
    // }

    AppUtils.UserSessionExpired();
  }

  @override
  void onCurrentLocationChange(value) {

  }

}