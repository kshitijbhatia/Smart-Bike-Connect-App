
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_colors.dart';
import '../constants/assets.dart';
import '../constants/strings.dart';
import '../features/my_bikes/presentation/controllers/my_bike_controller.dart';
import '../main.dart';

class BleLocListener extends ConsumerStatefulWidget {

  @override
  ConsumerState createState() => _BleLocListenerState();
}

class _BleLocListenerState extends ConsumerState<BleLocListener> {

  final StreamController<ServiceStatus> _locationStreamController = StreamController.broadcast();
  static final _platform = const MethodChannel(SMARTBIKE_PLUGIN);

  @override
  void initState() {
    super.initState();
    _locationListener();
  }

  Future<void> _locationListener() async {
    bool? serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(serviceEnabled == false){
      _locationStreamController.add(ServiceStatus.disabled);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(myBikeNativeController.notifier).notifyLocStatus(false);
      });
    }
    else{
      _locationStreamController.add(ServiceStatus.enabled);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(currentLocationController.notifier).getCurrentLocation();
        ref.read(myBikeNativeController.notifier).notifyLocStatus(true);
      });
    }

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
      if(!_locationStreamController.isClosed){
        _locationStreamController.add(status);
      }
      if(status == ServiceStatus.enabled){
        if(mounted){
          ref.read(currentLocationController.notifier).getCurrentLocation();
          ref.read(myBikeNativeController.notifier).notifyLocStatus(true);
        }

      }else{
        if(mounted) {
          ref.read(currentLocationController.notifier).cancelPositionStream();
          ref.read(myBikeNativeController.notifier).notifyLocStatus(false);
        }
      }
    });

    ///Updating Ble-Status from smartBike_plugin
    try{
      final bleState = await _platform.invokeMethod(Constants.BLUETOOTH_STATE, true);
      ref.read(myBikeNativeController.notifier).notifyBleStatus(bleState);
    }catch(e,stacktrace){
      log('BleStateExc $e',stackTrace: stacktrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child){
              final bleStatus = ref.watch(myBikeNativeController.select((value) => value.isBleOnOffStatus));
              if(bleStatus){
                return Image.asset(
                  icBluetooth,
                  scale: 2.5.h,
                );
              }else{
                return Image.asset(
                  icBluetooth,
                  scale: 2.5.h,color: greyEsColor,
                );
              }
            }
        ),
        StreamBuilder<ServiceStatus>(
            stream: _locationStreamController.stream,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == ServiceStatus.enabled) {
                return Image.asset(
                  icLocation,
                  scale: 2.5.h,
                );
              }
              return Image.asset(
                icLocation,color: greyEsColor,
                scale: 2.5.h,
              );
            }
        )
      ],
    );
  }


  @override
  void dispose() {
    super.dispose();
    log('bleLocListenerDisposed');
    _locationStreamController.close();
  }
}
