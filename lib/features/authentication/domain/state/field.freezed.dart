// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'field.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Field {
  String get value => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  List<Color> get buttonColor => throw _privateConstructorUsedError;
  bool get isColor => throw _privateConstructorUsedError;
  bool get isErrorBox => throw _privateConstructorUsedError;
  bool get textFieldVisibility => throw _privateConstructorUsedError;
  String get countryCode => throw _privateConstructorUsedError;
  String get isEmail => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FieldCopyWith<Field> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldCopyWith<$Res> {
  factory $FieldCopyWith(Field value, $Res Function(Field) then) =
      _$FieldCopyWithImpl<$Res, Field>;
  @useResult
  $Res call(
      {String value,
      String email,
      String phoneNumber,
      List<Color> buttonColor,
      bool isColor,
      bool isErrorBox,
      bool textFieldVisibility,
      String countryCode,
      String isEmail});
}

/// @nodoc
class _$FieldCopyWithImpl<$Res, $Val extends Field>
    implements $FieldCopyWith<$Res> {
  _$FieldCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? buttonColor = null,
    Object? isColor = null,
    Object? isErrorBox = null,
    Object? textFieldVisibility = null,
    Object? countryCode = null,
    Object? isEmail = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      buttonColor: null == buttonColor
          ? _value.buttonColor
          : buttonColor // ignore: cast_nullable_to_non_nullable
              as List<Color>,
      isColor: null == isColor
          ? _value.isColor
          : isColor // ignore: cast_nullable_to_non_nullable
              as bool,
      isErrorBox: null == isErrorBox
          ? _value.isErrorBox
          : isErrorBox // ignore: cast_nullable_to_non_nullable
              as bool,
      textFieldVisibility: null == textFieldVisibility
          ? _value.textFieldVisibility
          : textFieldVisibility // ignore: cast_nullable_to_non_nullable
              as bool,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      isEmail: null == isEmail
          ? _value.isEmail
          : isEmail // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_FieldCopyWith<$Res> implements $FieldCopyWith<$Res> {
  factory _$$_FieldCopyWith(_$_Field value, $Res Function(_$_Field) then) =
      __$$_FieldCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String value,
      String email,
      String phoneNumber,
      List<Color> buttonColor,
      bool isColor,
      bool isErrorBox,
      bool textFieldVisibility,
      String countryCode,
      String isEmail});
}

/// @nodoc
class __$$_FieldCopyWithImpl<$Res> extends _$FieldCopyWithImpl<$Res, _$_Field>
    implements _$$_FieldCopyWith<$Res> {
  __$$_FieldCopyWithImpl(_$_Field _value, $Res Function(_$_Field) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? buttonColor = null,
    Object? isColor = null,
    Object? isErrorBox = null,
    Object? textFieldVisibility = null,
    Object? countryCode = null,
    Object? isEmail = null,
  }) {
    return _then(_$_Field(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      buttonColor: null == buttonColor
          ? _value._buttonColor
          : buttonColor // ignore: cast_nullable_to_non_nullable
              as List<Color>,
      isColor: null == isColor
          ? _value.isColor
          : isColor // ignore: cast_nullable_to_non_nullable
              as bool,
      isErrorBox: null == isErrorBox
          ? _value.isErrorBox
          : isErrorBox // ignore: cast_nullable_to_non_nullable
              as bool,
      textFieldVisibility: null == textFieldVisibility
          ? _value.textFieldVisibility
          : textFieldVisibility // ignore: cast_nullable_to_non_nullable
              as bool,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      isEmail: null == isEmail
          ? _value.isEmail
          : isEmail // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_Field implements _Field {
  const _$_Field(
      {required this.value,
      this.email = '',
      this.phoneNumber = '',
      final List<Color> buttonColor = const [
        commonButtonDisabledColor,
        commonButtonDisabledColor
      ],
      this.isColor = false,
      this.isErrorBox = false,
      this.textFieldVisibility = true,
      this.countryCode = '91',
      this.isEmail = ''})
      : _buttonColor = buttonColor;

  @override
  final String value;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phoneNumber;
  final List<Color> _buttonColor;
  @override
  @JsonKey()
  List<Color> get buttonColor {
    if (_buttonColor is EqualUnmodifiableListView) return _buttonColor;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_buttonColor);
  }

  @override
  @JsonKey()
  final bool isColor;
  @override
  @JsonKey()
  final bool isErrorBox;
  @override
  @JsonKey()
  final bool textFieldVisibility;
  @override
  @JsonKey()
  final String countryCode;
  @override
  @JsonKey()
  final String isEmail;

  @override
  String toString() {
    return 'Field(value: $value, email: $email, phoneNumber: $phoneNumber, buttonColor: $buttonColor, isColor: $isColor, isErrorBox: $isErrorBox, textFieldVisibility: $textFieldVisibility, countryCode: $countryCode, isEmail: $isEmail)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Field &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            const DeepCollectionEquality()
                .equals(other._buttonColor, _buttonColor) &&
            (identical(other.isColor, isColor) || other.isColor == isColor) &&
            (identical(other.isErrorBox, isErrorBox) ||
                other.isErrorBox == isErrorBox) &&
            (identical(other.textFieldVisibility, textFieldVisibility) ||
                other.textFieldVisibility == textFieldVisibility) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.isEmail, isEmail) || other.isEmail == isEmail));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      value,
      email,
      phoneNumber,
      const DeepCollectionEquality().hash(_buttonColor),
      isColor,
      isErrorBox,
      textFieldVisibility,
      countryCode,
      isEmail);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FieldCopyWith<_$_Field> get copyWith =>
      __$$_FieldCopyWithImpl<_$_Field>(this, _$identity);
}

abstract class _Field implements Field {
  const factory _Field(
      {required final String value,
      final String email,
      final String phoneNumber,
      final List<Color> buttonColor,
      final bool isColor,
      final bool isErrorBox,
      final bool textFieldVisibility,
      final String countryCode,
      final String isEmail}) = _$_Field;

  @override
  String get value;
  @override
  String get email;
  @override
  String get phoneNumber;
  @override
  List<Color> get buttonColor;
  @override
  bool get isColor;
  @override
  bool get isErrorBox;
  @override
  bool get textFieldVisibility;
  @override
  String get countryCode;
  @override
  String get isEmail;
  @override
  @JsonKey(ignore: true)
  _$$_FieldCopyWith<_$_Field> get copyWith =>
      throw _privateConstructorUsedError;
}
