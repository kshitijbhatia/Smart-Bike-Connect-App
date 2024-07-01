// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$LocationState {
  LatLng? get currentLocation => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LocationStateCopyWith<LocationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationStateCopyWith<$Res> {
  factory $LocationStateCopyWith(
          LocationState value, $Res Function(LocationState) then) =
      _$LocationStateCopyWithImpl<$Res, LocationState>;
  @useResult
  $Res call({LatLng? currentLocation});
}

/// @nodoc
class _$LocationStateCopyWithImpl<$Res, $Val extends LocationState>
    implements $LocationStateCopyWith<$Res> {
  _$LocationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLocation = freezed,
  }) {
    return _then(_value.copyWith(
      currentLocation: freezed == currentLocation
          ? _value.currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as LatLng?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LocationPageStateCopyWith<$Res>
    implements $LocationStateCopyWith<$Res> {
  factory _$$_LocationPageStateCopyWith(_$_LocationPageState value,
          $Res Function(_$_LocationPageState) then) =
      __$$_LocationPageStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LatLng? currentLocation});
}

/// @nodoc
class __$$_LocationPageStateCopyWithImpl<$Res>
    extends _$LocationStateCopyWithImpl<$Res, _$_LocationPageState>
    implements _$$_LocationPageStateCopyWith<$Res> {
  __$$_LocationPageStateCopyWithImpl(
      _$_LocationPageState _value, $Res Function(_$_LocationPageState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLocation = freezed,
  }) {
    return _then(_$_LocationPageState(
      currentLocation: freezed == currentLocation
          ? _value.currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as LatLng?,
    ));
  }
}

/// @nodoc

class _$_LocationPageState extends _LocationPageState {
  const _$_LocationPageState({this.currentLocation = null}) : super._();

  @override
  @JsonKey()
  final LatLng? currentLocation;

  @override
  String toString() {
    return 'LocationState(currentLocation: $currentLocation)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LocationPageState &&
            (identical(other.currentLocation, currentLocation) ||
                other.currentLocation == currentLocation));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentLocation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LocationPageStateCopyWith<_$_LocationPageState> get copyWith =>
      __$$_LocationPageStateCopyWithImpl<_$_LocationPageState>(
          this, _$identity);
}

abstract class _LocationPageState extends LocationState {
  const factory _LocationPageState({final LatLng? currentLocation}) =
      _$_LocationPageState;
  const _LocationPageState._() : super._();

  @override
  LatLng? get currentLocation;
  @override
  @JsonKey(ignore: true)
  _$$_LocationPageStateCopyWith<_$_LocationPageState> get copyWith =>
      throw _privateConstructorUsedError;
}
