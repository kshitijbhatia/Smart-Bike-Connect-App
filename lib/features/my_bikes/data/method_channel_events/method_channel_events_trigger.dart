import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/data/method_channel_events/method_channel_service.dart';
import 'package:smartbike_flutter/features/my_bikes/data/method_channel_repo/method_channel_events_repo.dart';


final subscribeMethodChannel = Provider.autoDispose<MethodChannelEventsTrigger>((ref){
  return MethodChannelEventsTrigger(ref);
}
);

class MethodChannelEventsTrigger{

  static late MethodChannelService methodChannelService;

  final Ref _ref;
  MethodChannelEventsTrigger( this._ref){
    methodChannelService = MethodChannelEventHandler(_ref);
  }

  static Future<dynamic> handleNativeCallbacks(MethodCall call) async {

    switch(call.method) {

      case Constants.BLUETOOTH_STATE :
        bool bleState = call.arguments;
        log('bleState_Method $bleState');
        methodChannelService.onBleStateChange(bleState);
        return true;
        
      case Constants.SBM_CONNECTED :
        log('FlutterSide SBM_CONNECTED');
        methodChannelService.onSBMConnected();
        return true;

      case Constants.SBM_DISCONNECTED :
        log('FlutterSide SBM_DISCONNECTED');
         methodChannelService.onSBMDisconnected();
        return true;

      case Constants.NEW_BUTTON_STATE :
        dynamic newButtonState = call.arguments;
          methodChannelService.onButtonStateChange(newButtonState);
        log('newButtonState $newButtonState');
        return;

      case Constants.NEW_BIKE_STATE :
        dynamic newBikeState = call.arguments;
        methodChannelService.onBikeStateChange(newBikeState.toString());
        log('newBikeState $newBikeState');
        return;

      case Constants.LAST_PARK_LOCATION :
        dynamic lastParkedLocation = call.arguments;
        methodChannelService.onLastParkedLocationChange(lastParkedLocation);
        log('lastParkedLocation $lastParkedLocation');
        return;

      case Constants.BIKE_VICINITY :
        dynamic bikeRange = call.arguments;
        methodChannelService.onBikeVicinityChange(bikeRange);
        return;

      case Constants.LEARN_MODE_RESPONSE :
        bool result = call.arguments;
        methodChannelService.onSendLearnModeChange(result);
        return;

      case Constants.SMARTNESS_CHANGED :
        String result = call.arguments;
        methodChannelService.onSmartnessChange(result);
        return;

      case Constants.SBM_FIRMWARE_VERSION :
        String firmwareVer = call.arguments;
        methodChannelService.onFirmwareVersionReceived(firmwareVer);
        return;

      case Constants.SAS_TOKEN_EXPIRED :
        methodChannelService.onSasTokenExpired();
        return;

      case Constants.DFU_PROGRESS :
        int percentage = call.arguments;
        methodChannelService.onDfuProgress(percentage);
        return;

      case Constants.FAILED_TO_ADVERTISE :
        methodChannelService.onFailedToAdvertise(true);
        return;


    }
  }

}
