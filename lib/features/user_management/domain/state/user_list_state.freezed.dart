// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$UsersList {
  List<Users> get values => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UsersListCopyWith<UsersList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsersListCopyWith<$Res> {
  factory $UsersListCopyWith(UsersList value, $Res Function(UsersList) then) =
      _$UsersListCopyWithImpl<$Res, UsersList>;
  @useResult
  $Res call({List<Users> values});
}

/// @nodoc
class _$UsersListCopyWithImpl<$Res, $Val extends UsersList>
    implements $UsersListCopyWith<$Res> {
  _$UsersListCopyWithImpl(this._value, this._then);

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
              as List<Users>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UsersListCopyWith<$Res> implements $UsersListCopyWith<$Res> {
  factory _$$_UsersListCopyWith(
          _$_UsersList value, $Res Function(_$_UsersList) then) =
      __$$_UsersListCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Users> values});
}

/// @nodoc
class __$$_UsersListCopyWithImpl<$Res>
    extends _$UsersListCopyWithImpl<$Res, _$_UsersList>
    implements _$$_UsersListCopyWith<$Res> {
  __$$_UsersListCopyWithImpl(
      _$_UsersList _value, $Res Function(_$_UsersList) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
  }) {
    return _then(_$_UsersList(
      values: null == values
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as List<Users>,
    ));
  }
}

/// @nodoc

class _$_UsersList extends _UsersList {
  const _$_UsersList({required final List<Users> values})
      : _values = values,
        super._();

  final List<Users> _values;
  @override
  List<Users> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  String toString() {
    return 'UsersList(values: $values)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UsersList &&
            const DeepCollectionEquality().equals(other._values, _values));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_values));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UsersListCopyWith<_$_UsersList> get copyWith =>
      __$$_UsersListCopyWithImpl<_$_UsersList>(this, _$identity);
}

abstract class _UsersList extends UsersList {
  const factory _UsersList({required final List<Users> values}) = _$_UsersList;
  const _UsersList._() : super._();

  @override
  List<Users> get values;
  @override
  @JsonKey(ignore: true)
  _$$_UsersListCopyWith<_$_UsersList> get copyWith =>
      throw _privateConstructorUsedError;
}
