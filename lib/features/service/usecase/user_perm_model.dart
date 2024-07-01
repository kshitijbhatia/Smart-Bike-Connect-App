



import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_perm_model.freezed.dart';

@freezed
class UserPermModel with _$UserPermModel{

  const factory UserPermModel({
    @Default(false) bool isLearnModeAllowed,
    @Default(false) bool isAPrimaryUserAllowed,
    @Default(false) bool isCURDSecondaryUserAllowed,
    @Default(false) bool isSmartnessControl,
    @Default(false) bool isCURDSBMAllowed,
    @Default(false) bool isBikeAdminViewAllowed,
    @Default(false) bool isSuperAdmin,
    @Default(false) bool isDealerAdmin,
    @Default(false) bool isDealerUser,
  }) = UserPermModelState;

  const UserPermModel._();
}