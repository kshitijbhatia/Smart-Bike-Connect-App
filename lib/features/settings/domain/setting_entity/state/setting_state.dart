import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting_state.freezed.dart';


@freezed
class SettingState with _$SettingState{

  const factory SettingState({
    @Default('English') String languageText,
    @Default('') String firmwareVersion,
    @Default(0) int selectedIndex,
    @Default(1) int smartnessValue,
    @Default(false) bool isSendLearnModeLoader,
    @Default(false) bool smartnessColor,
    @Default('') String userName,
    @Default('') String email,
    @Default(0 ) int phoneNumber,
    @Default('My Bikes') String roleName,
    @Default(91) int countryCode,
    @Default(false) bool profileUpdateErrorBox,
    @Default(false) bool dfuButtonVisibility,
    @Default(null) int? dfuProgressPercentage
  }) = _SettingPageState;

  const SettingState._();

}

