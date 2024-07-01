import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:smartbike_flutter/features/authentication/presentation/screens/new_otp_screen.dart';
import 'package:smartbike_flutter/features/authentication/presentation/screens/otp_screen.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';

import '../../../../main.dart';
import '../../../my_bikes/presentation/controllers/my_bike_controller.dart';
import '../../../settings/presentation/controllers/setting_controller.dart';
import '../../../user_management/presentation/controllers/user_management_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  TextEditingController phoneNumberTextController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  TextEditingController emailTextController = TextEditingController();
  final _platform = const MethodChannel(SMARTBIKE_PLUGIN);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.invalidate(myBikeNativeController);
      ref.invalidate(settingController);
      ref.invalidate(userProvider);
      final String defaultLocale = Platform.localeName;
      developer.log('default_locale_of_phone $defaultLocale');
      checkAppUpdate(context,_platform);
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log('saved_locale_is ${context.locale}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 50.h, left: 18.w, right: 18.w),
          decoration: BoxDecoration(color: whiteColor),
          child: bodyView(),
        ),
      ),
    );
  }

  /*========================================body View=================================*/

  Widget  bodyView(){
    return SingleChildScrollView(
      child: Column(
        children: [
          10.ph,
          Container(child: Image.asset(icTVSLogo ,width:150.w,height: 50.h,),),
          45.ph,
          text(title: LocaleKeys.keyLogin.tr(), fontSize: 24.sp, fontWeight: FontWeight.w600,),
          25.ph,
          _phoneNumberTextFormFieldView(),
          _helperText(),
          20.ph,
          _getOTPButton(),
          15.ph,
          _loginUsingTextView(),
          25.ph,
          dividerView(),
          30.ph,
          _loginWithGoogleButton(),
          Platform.isAndroid ? Container() : Container(margin: EdgeInsets.only(top: 12.h),child: _loginWithAppleButton(),),
        ],
      ),
    );
  }

  /*========================================text Form Field View==================================*/

  Widget _phoneNumberTextFormFieldView({bool? fieldVisibility}){
    return  Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final visibility = ref.watch(authProvider.select((value) => value.formState.textFieldVisibility.textFieldVisibility));
          var errorVisible = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isErrorBox));
          return Visibility(
            visible:  fieldVisibility ?? visibility,replacement: _emailTextFormFieldView(),
            child: textFormField(
                focusNode: phoneFocusNode,
                hasError: errorVisible,
                hintFontSize: 16.sp,
                textInputAction : TextInputAction.done,
                suffixOnTab: (){
                  phoneNumberTextController.clear();
                  ref.watch(authProvider.notifier).setGetOtpButtonColor('',emailText: '');
                },
                prefixIcon: InkWell(
                  onTap: (){
                    showCountryPicker(
                      favorite: ['IN'],
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        ref.watch(authProvider.notifier).setCountryCode(country.phoneCode);
                      },
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      10.pw,
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref, Widget? child) {
                          var countryCode = ref.watch(authProvider.select((value) => value.formState.countryCode.countryCode));
                          return Padding(
                            padding:  EdgeInsets.only(top: 0.h),
                            child: text(title: "+$countryCode", fontSize: 16.sp, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                      Container(
                        width: 22.w,
                        child: Icon(Icons.keyboard_arrow_down, color: formArrowDownIconColor,),
                      ),
                      2.pw,
                      Container(
                          height: 40.h,
                          width: 3.w,
                          child: VerticalDivider(color: verticalDividerColor ,thickness: 1.w,indent: 4.h,endIndent: 4.h,)),
                      6.pw,
                    ],),
                ),
                onChanged: (value){
                  ref.watch(authProvider.notifier).setGetOtpButtonColor(value);
                },
                hintText: LocaleKeys.keyLoginHint.tr(),
                controller:  phoneNumberTextController,
                maxLength: 12,
                contentPadding: EdgeInsets.only(top: 4.h)
            ),
          );
        });
  }


  Widget _emailTextFormFieldView(){
    return  Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          var errorVisible = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isErrorBox));
          return textFormField(
              hasError: errorVisible,
              inputFormatters: [],
              suffixOnTab: (){
                emailTextController.clear();
                ref.watch(authProvider.notifier).setGetOtpButtonColor('',emailText: '');
              },
              keyboardType: TextInputType.emailAddress,
              hintText: LocaleKeys.keyEmailHint.tr(),
              textInputAction : TextInputAction.done,
              controller: emailTextController,
              onChanged: (value) {
                ref.watch(authProvider.notifier).setGetOtpButtonColor('',emailText: value);
              },
              contentPadding: EdgeInsets.only(top: 4.h, left: 14.w),
              maxLength: 255,
          );
        });
  }

  /*========================================text Form Field Helper Text==================================*/

  Widget _helperText(){
    return Consumer(
      builder: (context, ref, child) {
        var errorVisible = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isErrorBox));
        final isEmail = ref.watch(authProvider.select((value) => value.formState.isEmailLogin.isEmail));
        final visibility = ref.watch(authProvider.select((value) => value.formState.textFieldVisibility.textFieldVisibility));
        if(errorVisible){
          return errorWidget(subTitle: isEmail != ''? LocaleKeys.keyLoginEmailErrorMsg.tr() : LocaleKeys.keyLoginErrorMsg.tr());
        }else{
          return Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 6.h),
              child: text(
                  title: visibility ? LocaleKeys.keyTextFieldHelperTextMobile.tr() : LocaleKeys.keyTextFieldHelperTextEmail.tr(),
                  color: formHelperTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp
              )
          );
        }
      },
    );
  }

  /*==========================================get OTP Button====================================*/

  Widget _getOTPButton(){
    return  Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final auth = ref.watch(authProvider.notifier);
        var countryCode = ref.watch(authProvider.select((value) => value.formState.countryCode.countryCode));
        bool isPhoneTextFiled = ref.watch(authProvider.select((value) => value.formState.textFieldVisibility.textFieldVisibility));
        bool isColor = ref.read(authProvider.select((value) => value.formState.phoneNumber.isColor));
        return commonButton(
            changeTextColor: isColor,
            buttonColor: ref.watch(authProvider.select((value) => value.formState.phoneNumber.buttonColor)),
            buttonText:  LocaleKeys.keyGetOtp.tr(),
            onTap: ref.watch(authProvider.select((value) => value.formState.phoneNumber.isColor == false)) ? (){} : () async {
              bool response = false;
              FocusScope.of(context).requestFocus(FocusNode());
              CustomLoaderDialog.buildShowDialog(context);
              isPhoneTextFiled == true ?
              response = await auth.generateOtp(phoneNumber: phoneNumberTextController.text.trim(), countryCode: '+$countryCode') :
              response = await auth.generateOtp(email: emailTextController.text.trim());
              if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
              if (response == true) {
                ref.watch(authProvider.notifier).setGetOtpButtonColor(phoneNumberTextController.text, disableButton: true);
                phoneNumberTextController.clear();
                emailTextController.clear();
                Navigator.push(this.context, MaterialPageRoute(builder: (context) => const OTPScreen()));
              }
            });
      },
    );
  }

  /*========================================_login With Google Button====================================*/

  Widget _loginWithGoogleButton(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return commonButton(
            hasBorder: true,
            isIconButton: true,
            buttonImage: icGoogle,
            buttonText: LocaleKeys.keyLoginGoogle.tr(),
            buttonColor: [
              whiteColor,
              whiteColor,
            ],
            onTap: () async {
              String email = await ref.watch(authProvider.notifier).logInGoogle();
              if(email != ''){
                ref.watch(authProvider.notifier).setGetOtpButtonColor('',emailText: email);
                ref.watch(authProvider.notifier).setTextFiledVisibility('false');
                emailTextController.text = email;
                CustomLoaderDialog.buildShowDialog(context);
                final response =  await ref.watch(authProvider.notifier).generateOtp(email: email);
                if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                if(response == true){
                  ref.watch(authProvider.notifier).setTextFiledVisibility('true');
                  ref.watch(authProvider.notifier).setGetOtpButtonColor('');
                  Navigator.push(this.context, MaterialPageRoute(builder: (context) => const OTPScreen()));
                }
              }else{
                developer.log('email not found');
              }
            } );
      },
    );
  }

  /*========================================_login With Apple Button====================================*/

  Widget _loginWithAppleButton(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return commonButton(
            hasBorder: true,
            isIconButton: true,
            buttonText:  LocaleKeys.keyLoginApple.tr(),
            buttonColor: [
              whiteColor,
              whiteColor,
            ],
            buttonImage: icApple,
            onTap: () async {
              /// New flow for apple login
              bool? appleSign = await ref.watch(authProvider.notifier).logInApple();
              if( appleSign != null && appleSign == true) {
                phoneNumberTextController.clear();
                ref.watch(authProvider.notifier).setGetOtpButtonColor('');
                appleLoginBottomSheetView();
              }
              /*   String? email = await ref.watch(authProvider.notifier).logInApple();
          if(email != ''){
            ref.watch(authProvider.notifier).setGetOtpButtonColor('',emailText: email!);
            ref.watch(authProvider.notifier).setTextFiledVisibility('false');
            emailTextController.text = email;
            CustomLoaderDialog.buildShowDialog(context);
            final response =  await ref.watch(authProvider.notifier).generateOtp(email: email);
            if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
            if(response == true){
              ref.watch(authProvider.notifier).setTextFiledVisibility('true');
              ref.watch(authProvider.notifier).setGetOtpButtonColor('');
              Navigator.push(this.context, MaterialPageRoute(builder: (context) => const OtpScreen()));
            }
          }else{
            developer.log('email not found');
          }*/
            } );
      },
    );
  }

  /*=========================================login Using Text View===================================*/

  Widget  _loginUsingTextView(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final visibility = ref.watch(authProvider.select((value) => value.formState.textFieldVisibility.textFieldVisibility));
        return InkWell(
            onTap: (){
              ref.watch(authProvider.notifier).setErrorBox('');
              emailTextController.clear();
              phoneNumberTextController.clear();
              ref.watch(authProvider.notifier).setGetOtpButtonColor('');
              if(visibility == false){
                ref.watch(authProvider.notifier).setTextFiledVisibility('true');
              }else{
                ref.watch(authProvider.notifier).setTextFiledVisibility('false');
              }
            },
            child: Container(
              height: 25.h,
              child: text(
                  title: visibility == true ? LocaleKeys.keyLoginUsingEmail.tr() : LocaleKeys.keyLoginUsingPhone.tr(),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: blueTextButtonColor,
                  fontFamily: "Nunito",
                  textAlign: TextAlign.center
              ),
            )
            );}
    );
  }

  /*==========================================divider View====================================*/

  Widget dividerView(){
    return  Row(
      children:  [
        Expanded(child: Divider(color: horizontalDividerColor,thickness: 1.h,)),
        8.pw,
        text(title: LocaleKeys.keyOr.tr(), color: horizontalDividerTextColor, fontSize: 14.sp, fontWeight: FontWeight.w500, fontFamily: "Nunito"),
        8.pw,
        Expanded(child: Divider(color: horizontalDividerColor,thickness: 1.h))
      ],);
  }

  /*=======================================apple login Bottom Sheet View================================================*/

  void appleLoginBottomSheetView() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.r),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height /1.1,
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
            color: whiteColor,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: (){
                      phoneNumberTextController.clear();
                      emailTextController.clear();
                      ref.watch(authProvider.notifier).setGetOtpButtonColor('');
                      Navigator.pop(context);
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Transform.translate(
                        offset: Offset(10.h,0),
                        child: Icon(
                          Icons.clear,
                          color: greyEsColor,
                          size: 30.h,
                        ),
                      ),
                    ),
                  ),
                  10.ph,
                  text(
                    title: LocaleKeys.keyEnterMobileNumber.tr(),
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                  5.ph,
                  text(
                    title:  LocaleKeys.keyCodeVerificationDes.tr(),
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    maxLines: 3,
                  ),
                  20.ph,
                  _phoneNumberTextFormFieldView(fieldVisibility: true),
                  Consumer(
                    builder: (context, ref, child) {
                      var errorVisible = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isErrorBox));
                      return Visibility(
                        visible: errorVisible,
                        child: errorWidget(subTitle: LocaleKeys.keyLoginErrorMsg.tr()),
                      );
                    },
                  ),
                  20.ph,
                  _getOTPButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}