

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartbike_flutter/constants/strings.dart';

part 'bike_detail_state.freezed.dart';


@freezed
class BikeDetailsState with _$BikeDetailsState{

  const factory BikeDetailsState({
    @Default('NOT_SEEN') String bikeVicinity,
    @Default('')    String buttonState,
    @Default('')    String bikeStateText,
    @Default('')    String lastParkedAddress,
    @Default(SBM_STATE.DISCONNECTED) SBM_STATE sbmStatus,
    @Default('')    dynamic lastParkedLocation,
    @Default('')    String smartnessChanged,
    @Default(false) bool isSliding,
    @Default(0.0)   double slidePosition,
    @Default('')    String userName,
    @Default(null)  bool? isRole,
    @Default(false) bool isBlePermGranted,
    @Default(false) bool isLocPermGranted,
    @Default(false) bool isBleOnOffStatus,
    @Default(false) bool isLocOnOffStatus,
    @Default(false) bool noScanBLEWarning,
    @Default('')    String bikeFriendlyName,
    Uint8List? markerIcon,

  }) = _SbmTagPageState;

  const BikeDetailsState._();
}