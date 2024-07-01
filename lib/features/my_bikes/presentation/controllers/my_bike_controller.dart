import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/state/bike_detail_state.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/state/bike_list_state.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/state/location_state.dart';
import 'package:smartbike_flutter/features/service/app_service.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/network/exception.dart';
import 'package:smartbike_flutter/smartbike_database/smartbike_db_repo.dart';
import 'package:smartbike_flutter/widgets/toast.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../network/api_end_points.dart';
import '../../../service/user_perm_controller.dart';
import '../../../settings/presentation/controllers/setting_controller.dart';



/*===========================================my bike api controller======================================*/

final myBikeAPIController = StateNotifierProvider.autoDispose<MyBikeApiControllerClass, AsyncValue<BikeList>>((ref) {
  return MyBikeApiControllerClass(ref);
});


class MyBikeApiControllerClass extends StateNotifier<AsyncValue<BikeList>> {

  final Ref _ref;
  MyBikeApiControllerClass(this._ref) : super(const AsyncValue.loading()){
    getAllBikes(start: 0,limit: 10);
  }

  getAllBikes({ required int start ,required int limit}) async {

    late final bikeList;

    try{

      if(start == 0)  state = await AsyncValue.loading();

      if(_ref.read(userPermController).isSuperAdmin || _ref.read(userPermController).isDealerAdmin || _ref.read(userPermController).isDealerUser){
        bikeList = await _ref.read(applicationService).getAllBikes(start: start,limit: limit, apiEndPoint: bikeListEndPoint);
      }else{
        bikeList = await _ref.read(applicationService).getAllBikes(start: start,limit: limit, apiEndPoint: bikeListEndPoint);
      }

      ///Updating Database
      await _ref.read(dbRepoProvider).deleteAllBikes();
      await _ref.read(dbRepoProvider).insertAllBikes(bikeList.values);
      final updatedBikeList = await _ref.read(dbRepoProvider).updateBikeDataAttributes(bikeList.values);
      state = await AsyncValue.data(BikeList(values: updatedBikeList));

    } on DatabaseException catch(e,stackTrace){
      log('getAllBikesExceptionDb: $e', stackTrace: stackTrace);
      if(bikeList != null){
        state = await AsyncValue.data(bikeList);
        showToast(LocaleKeys.toastErrorSavingData.tr(),warning: true);
        return;
      }else{
        state = AsyncValue.error(LocaleKeys.toastServiceUnavailable.tr(), stackTrace);
      }
    } on DataException catch(e,stackTrace){
      log('getAllBikesExceptionAPI: $e', stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }catch(e,stackTrace){
      log('getAllBikesExceptionUk: $e', stackTrace: stackTrace);
      state = AsyncValue.error(LocaleKeys.toastGenericMsg.tr(), stackTrace);
    }
  }

}

/*============================================for native controller======================================*/

final myBikeNativeController = StateNotifierProvider<MyBikeNativeControllerClass, BikeDetailsState>((ref) => MyBikeNativeControllerClass(ref));

class MyBikeNativeControllerClass extends StateNotifier<BikeDetailsState>{

  Ref _ref;

  MyBikeNativeControllerClass(this._ref) : super(BikeDetailsState());

  bikeVicinityStatusState(final String bikeVicinity){
    state = state.copyWith(bikeVicinity: bikeVicinity);
  }

  bikeButtonStatus(final String buttonState){
    state = state.copyWith(buttonState: buttonState);
  }

  sbmStatusState(final SBM_STATE sbmStatus){
    state = state.copyWith(sbmStatus: sbmStatus);
   if(sbmStatus == SBM_STATE.DISCONNECTED){
     _ref.watch(settingController.notifier).setDFUButtonVisibility(false);
   }
  }

  lastParkedLocationState(final dynamic lastParkedLocation){
    state = state.copyWith(lastParkedLocation: lastParkedLocation);
  }

  bikeStateUpdate(final String newState){
    log('bikeStateUpdated  $newState');
    state = state.copyWith(bikeStateText: newState);
  }

  fetchBikeLastParkedLocFromDB(final int bikeId) async{
    Map<String,dynamic> bikeLastParLoc = await _ref.read(dbRepoProvider).fetchBikeLastParkedLocation(bikeId);
    if(bikeLastParLoc.isNotEmpty){
      lastParkedLocationState(bikeLastParLoc);
    }
  }

  updateBikeLastParkedAddress(final String parkedAddress){
    state = state.copyWith(lastParkedAddress: parkedAddress);
  }

  sendLearnMode(final bool newState){

    _ref.watch(settingController.notifier).setSendLearnModeLoader(false);
    if(newState){
      showToast(LocaleKeys.toastLearnModeSent.tr(),centerGravity: true,warning: false);
    }else{
      showToast(LocaleKeys.toastFailedLearnMode.tr(),warning: true,duration: true);
    }
  }

  smartnessChanged(final String smartnessChanged){
    state = state.copyWith(smartnessChanged: smartnessChanged);
  }

  setSlideAnimation(final bool isSliding){
    state = state.copyWith(isSliding: isSliding);
  }

  setSlidePosition(final double position){
    state = state.copyWith(slidePosition: position);
  }

  setUserName(final String name){
    state = state.copyWith(userName: name);
  }

  setMapMarkers(final Uint8List? markerIcon){
    state = state.copyWith(markerIcon: markerIcon);
  }
  setHomePageView(final bool isRole){
    state = state.copyWith(isRole: isRole);
  }

  updateBikeState(final int bikeId, final int bikeState) async{
    try{
      await _ref.read(dbRepoProvider).updateBikeState(bikeId, bikeState);
    }catch(e,stackTrace){
      log('updateBikeStatesException: $e', stackTrace: stackTrace);
    }
  }

  updateBlePermission(bool isBlePermStatus){
    state = state.copyWith(isBlePermGranted: isBlePermStatus);
  }

  updateLocPermission(bool isLocPermStatus){
    state = state.copyWith(isLocPermGranted: isLocPermStatus);
  }

  notifyBleStatus(bool bleStatus){
    state = state.copyWith(isBleOnOffStatus: bleStatus);
  }

  notifyLocStatus(bool locStatus){
    state = state.copyWith(isLocOnOffStatus: locStatus);
  }

  setBikeFriendlyName( String bikeFriendlyName){
    state = state.copyWith(bikeFriendlyName : bikeFriendlyName);
  }

  setFailedToAdvertiseWarning(bool warningState){
    state = state.copyWith(noScanBLEWarning: warningState);
  }

  clearBikeBLEMeta(){
    bikeButtonStatus('');
    bikeStateUpdate('');
    bikeVicinityStatusState('NOT_SEEN');
    lastParkedLocationState('');
    updateBikeLastParkedAddress('');
  }

}

final currentLocationController = StateNotifierProvider<LocationController, LocationState>((ref) => LocationController(ref));

class LocationController extends StateNotifier<LocationState> {
  LocationController(this.ref) : super(LocationState());
  final Ref ref;
  StreamSubscription<Position>? _positionStream;

  Future<void> getCurrentLocation() async {

    log('startedGetCurrentLocation');
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever){
    }else{
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(serviceEnabled){
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        final currentPosition = LatLng(position.latitude, position.longitude);
        setCurrentLocation(LatLng(position.latitude, position.longitude));
        _startLocationUpdates();
        // log('current_loc_timestamp ${position.timestamp}');
        // log('Current location: $currentPosition');
      }
    }
  }

  void _startLocationUpdates() async{

    try{
      final LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 20);
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(serviceEnabled){
        _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
          if(position != null){
            setCurrentLocation(LatLng(position.latitude, position.longitude));
          }
        });
      }
    }catch(e,stacktrace){
      log('getLocationUpdatesExc',stackTrace: stacktrace);
    }
  }

  setCurrentLocation(final LatLng latLng){
    state = state.copyWith(currentLocation: latLng );
  }

  cancelPositionStream(){
    if(_positionStream != null){
      _positionStream!.cancel();
    }
  }

  @override
  void dispose() {
    if(_positionStream != null){
      _positionStream!.cancel();
    }
    super.dispose();
  }
}