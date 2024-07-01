

import 'package:freezed_annotation/freezed_annotation.dart';

import 'login_entity.dart';

part 'login_form.freezed.dart';

@freezed
class LoginForm with _$LoginForm {
  const factory LoginForm(LoginEntity formState) = _LoginForm;
}







