// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bike_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BikeList {
  List<BikeData> get values => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BikeListCopyWith<BikeList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BikeListCopyWith<$Res> {
  factory $BikeListCopyWith(BikeList value, $Res Function(BikeList) then) =
      _$BikeListCopyWithImpl<$Res, BikeList>;
  @useResult
  $Res call({List<BikeData> values});
}

/// @nodoc
class _$BikeListCopyWithImpl<$Res, $Val extends BikeList>
    implements $BikeListCopyWith<$Res> {
  _$BikeListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
  }) {
    return _then(_value.copyWith(
      values: null == values
          ? _value.values
          : values // ignore: cast_nullable_to_non_nullable
              as List<BikeData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BikeListCopyWith<$Res> implements $BikeListCopyWith<$Res> {
  factory _$$_BikeListCopyWith(
          _$_BikeList value, $Res Function(_$_BikeList) then) =
      __$$_BikeListCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BikeData> values});
}

/// @nodoc
class __$$_BikeListCopyWithImpl<$Res>
    extends _$BikeListCopyWithImpl<$Res, _$_BikeList>
    implements _$$_BikeListCopyWith<$Res> {
  __$$_BikeListCopyWithImpl(
      _$_BikeList _value, $Res Function(_$_BikeList) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
  }) {
    return _then(_$_BikeList(
      values: null == values
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as List<BikeData>,
    ));
  }
}

/// @nodoc

class _$_BikeList extends _BikeList {
  const _$_BikeList({required final List<BikeData> values})
      : _values = values,
        super._();

  final List<BikeData> _values;
  @override
  List<BikeData> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  String toString() {
    return 'BikeList(values: $values)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BikeList &&
            const DeepCollectionEquality().equals(other._values, _values));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_values));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BikeListCopyWith<_$_BikeList> get copyWith =>
      __$$_BikeListCopyWithImpl<_$_BikeList>(this, _$identity);
}

abstract class _BikeList extends BikeList {
  const factory _BikeList({required final List<BikeData> values}) = _$_BikeList;
  const _BikeList._() : super._();

  @override
  List<BikeData> get values;
  @override
  @JsonKey(ignore: true)
  _$$_BikeListCopyWith<_$_BikeList> get copyWith =>
      throw _privateConstructorUsedError;
}
