import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlng/latlng.dart';

part 'location_state.freezed.dart';


@freezed
class LocationState with _$LocationState{

  const factory LocationState({
    @Default(null) LatLng? currentLocation,
  }) = _LocationPageState;

  const LocationState._();

}