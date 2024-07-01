
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartbike_flutter/features/authentication/domain/state/field.dart';

import '../../../../constants/app_colors.dart';

part 'login_entity.freezed.dart';


@freezed
class LoginEntity with _$LoginEntity{

  const LoginEntity._();

  factory LoginEntity({
    required Field isErrorBoxShow,
    required Field phoneNumber,
    required Field otp,
    required Field Email,
    required  Field countryCode,
    required  Field textFieldVisibility,
    required  Field isEmailLogin,
    required dynamic resendOTPButtonColor,
    required Color resendOTPButtonTextColor,
  }) = _LoginEntity;

  factory LoginEntity.empty() => LoginEntity(phoneNumber: Field( value: ''),isErrorBoxShow: Field( value: ''), otp: Field( value: ''),
                                                          countryCode: Field(value: '91'), Email: Field( value: ''), textFieldVisibility: Field(value: ''),
                                                                isEmailLogin:  Field(value: ''),resendOTPButtonColor: Colors.grey.withOpacity(.5),
                                                                   resendOTPButtonTextColor: whiteColor);

}
