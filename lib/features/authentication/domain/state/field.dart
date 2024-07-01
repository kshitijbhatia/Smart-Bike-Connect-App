import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
part 'field.freezed.dart';
@freezed
class Field with _$Field {
  const factory Field({
    required String value,
    @Default('') String email,
    @Default('') String phoneNumber,
    @Default([ commonButtonDisabledColor, commonButtonDisabledColor ]) List<Color> buttonColor,
    @Default(false) bool isColor,
    @Default(false) bool isErrorBox,
    @Default(true) bool textFieldVisibility,
    @Default('91') String countryCode,
    @Default('') String isEmail,
  }) = _Field;
}