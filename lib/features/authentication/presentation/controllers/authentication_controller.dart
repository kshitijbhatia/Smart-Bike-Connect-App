import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:smartbike_flutter/features/authentication/domain/state/field.dart';
import 'package:smartbike_flutter/features/authentication/domain/state/login_entity.dart';
import 'package:smartbike_flutter/features/authentication/domain/state/login_form.dart';
import 'package:smartbike_flutter/features/service/app_service.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

import '../../../../constants/app_colors.dart';
import '../../../service/user_perm_controller.dart';

final authProvider = StateNotifierProvider<AuthController, LoginForm>((ref) => AuthController(ref));

class AuthController extends StateNotifier<LoginForm> {
  final Ref ref;
  AuthController(this.ref) : super(LoginForm(LoginEntity.empty()));
  GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? googleSignInAccount;
  late LoginEntity _form;
  String transactionId = '';
  String? _phoneNumber,_countryCode,_email;
  /*==========================================generate Otp====================================*/

  Future <bool> generateOtp({ String? phoneNumber, String? countryCode, String? email})  async{
   String? transId;
   try{
     _phoneNumber = phoneNumber;
     _countryCode = countryCode;
     _email = email;
     dev.log('phone: $_phoneNumber email : $_email');
     transId =  await  ref.read(applicationService).generateOtp(phoneNumber:phoneNumber ,countryCode: countryCode,email: email);
     if(transId != null){
       if(transId == 'no_user_found'){
         if(email != ""){
           checkEmailField(email??"");
         }
         setErrorBox(transId);
         return false;
       }else{
         transactionId = transId;
         if(email != ""){
           checkEmailField(email??"");
         }
         setErrorBox(transId);
         return true;
       }

     }else{
       setErrorBox('');
       return false;
     }

   }catch(e){
     showToast(e.toString(),warning: true,duration: true);
     setErrorBox('');
     dev.log('generateOTP ${e.toString()}');
     return false;
   }
  }


  /*=========================================log In Google==================================*/

  Future <String> logInGoogle() async {
    try {
      bool isLogin = await googleSignIn.isSignedIn();
      if(isLogin == true){
        googleSignInAccount = await googleSignIn.signOut();
      }
      googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        dev.log("email_is ${googleSignInAccount!.email}");
        return googleSignInAccount!.email;
      }else{
        return '';
      }
    }  catch (e,stacktrace) {
      dev.log('signInGoogleExc : ${e.toString()}',stackTrace: stacktrace);
      return '';
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /*=========================================log In Apple==================================*/

  Future<bool?> logInApple() async {
    try {

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      var redirectURL = "https://sbmconnect-44ac8.firebaseapp.com/__/auth/handler";
       var clientID = "650591625785-lrhj8cmh2ffos6v28422cubpe7l78qsi.apps.googleusercontent.com";
      AuthorizationCredentialAppleID credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName,],
          //nonce: nonce
          // webAuthenticationOptions: WebAuthenticationOptions(
          //     clientId: clientID,
          //     redirectUri: Uri.parse(
          //         redirectURL))
      );
      dev.log('CredentialAppleID userIdentifier :  ${credential.userIdentifier} EMAIL : ${credential.email} authorizationCode :  ${credential.authorizationCode} state :  ${credential.state} familyName : ${credential.familyName} givenName: ${credential.givenName} identityToken : ${credential.identityToken}');
      if(credential.userIdentifier != null){
        CredentialState credentialState = await SignInWithApple.getCredentialState(credential.userIdentifier!);
        dev.log('credentialName : ${credentialState}');
        if(CredentialState.authorized == credentialState){
          return true;
        }
        else{
          return false;
        }
      }
    }  catch (e,stacktrace) {
      dev.log('signInAppleExc : ${e.toString()}',stackTrace: stacktrace);
      return false;
    }
    return null;
  }

  /*=========================================set Error Box===================================*/

  setErrorBox(String value){
    _form = state.formState.copyWith(isErrorBoxShow: Field(value: value));
    late Field showErrorBox;
    if(value.trim() ==  'no_user_found'){
      showErrorBox = _form.isErrorBoxShow.copyWith(isErrorBox: true);
    }else{
      showErrorBox = _form.isErrorBoxShow.copyWith(isErrorBox: false);
    }
    state = state.copyWith(formState: _form.copyWith(isErrorBoxShow: showErrorBox));
  }

  setResendOTPButtonColor(bool isEnable){
      if(isEnable){
        state = state.copyWith(formState: _form.copyWith(resendOTPButtonColor: blueColor.withOpacity(.2), resendOTPButtonTextColor: buttonTextColor));
      }else{
        state = state.copyWith(formState: _form.copyWith(resendOTPButtonColor: Colors.grey.withOpacity(.5), resendOTPButtonTextColor: whiteColor));
      }
  }

  Future<bool> resendOTP() async{

      bool isOTPGenerated = await generateOtp(phoneNumber: _phoneNumber, countryCode: _countryCode,email: _email);
      if(isOTPGenerated){
        return true;
      }else{
        return false;
      }
  }

  /*==========================================validate Otp====================================*/

  Future <bool>  validateOtp({required String otp})  async {
    try {
      bool? response = await ref.read(applicationService).validateOtp(otp: otp, txnId: transactionId);
      if(response != null){
        await ref.read(userPermController.notifier).initPermMapping();
        return true;
      }
      else{
        return false;
      }
    }catch(e){
      dev.log('$e');
      setOtpFormColor(e.toString(),showError: true);
      return false;
    }
  }

  bool validateOtpField(List<TextEditingController> controllers){
    bool isComplete = controllers.every((element) => element.text.length == 1);
    _form = state.formState.copyWith(isErrorBoxShow: Field(value: ''));
    if(isComplete){
      ref.read(authProvider.notifier).setOtpFormColor('', isColor: true, showError: false);
    }
    return isComplete;
  }

  /*==========================================form validation of login and OTP and Pin page===================================*/

  setGetOtpButtonColor(String phone,{String emailText ='', bool disableButton = false}) {
    final isEmail = RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(emailText);

    _form = state.formState.copyWith(phoneNumber: Field(value: phone));
    late Field phoneNumber;
    if (phone.trim().length < 6 && isEmail == false) {
      phoneNumber = _form.phoneNumber.copyWith(isColor : false, buttonColor: [commonButtonDisabledColor, commonButtonDisabledColor]);
    } else {
      if(disableButton) phoneNumber = _form.phoneNumber.copyWith(isColor : false, buttonColor: [commonButtonDisabledColor, commonButtonDisabledColor]);
      else phoneNumber = _form.phoneNumber.copyWith(isColor: true, buttonColor: [ blueTextButtonColor, blueTextButtonColor]);
    }
    setErrorBox('');
    state = state.copyWith(formState: _form.copyWith(phoneNumber: phoneNumber));
  }

  setCreatePinButtonColor(String pin, String confirmPin, {String error = ''}){
    if(pin.length == 4 && confirmPin.length == 4){
      _form = state.formState.copyWith(isErrorBoxShow: Field(value: error, isColor: true));
    }else{
      _form = state.formState.copyWith(isErrorBoxShow: Field(value: error, isColor: false));
    }
    state = state.copyWith(formState: _form);
  }

  setEnterPinButtonColor(List<TextEditingController> controllers){
    final result = controllers.every((element) => element.text.length == 1);

    _form = state.formState.copyWith(isErrorBoxShow: Field(value: ''));
    late Field pinField;
    if(result) {
      pinField = _form.isErrorBoxShow.copyWith(isColor: true);
    }else{
      pinField = _form.isErrorBoxShow.copyWith(isColor: false);
    }
    state = state.copyWith(formState: _form.copyWith(isErrorBoxShow: pinField));
  }

  setLoginButtonColor(String otp) {
    _form = state.formState.copyWith(otp: Field(value: otp));
    late Field otpField;
    if (otp.trim().length < 4) {
      otpField = _form.otp.copyWith(isColor: false, buttonColor: [Colors.grey,Colors.grey], );
    } else {
      otpField = _form.otp.copyWith(isColor: true, buttonColor: [ const Color.fromRGBO(47, 64, 126,  1.0), const Color.fromRGBO(109, 69, 194, 1.0)]);
    }
    state = state.copyWith(formState: _form.copyWith(otp: otpField));
  }

  setOtpFormColor(String value, {bool showError = false, isColor = false}){
    _form = state.formState.copyWith(isErrorBoxShow: Field(value: value));
    late Field errorField;
    if(showError){
      errorField = _form.isErrorBoxShow.copyWith(isErrorBox: true, isColor: isColor);
    }else{
      errorField = _form.isErrorBoxShow.copyWith(isErrorBox: false, isColor: isColor);
    }
    state = state.copyWith(formState: _form.copyWith(isErrorBoxShow: errorField));
  }


  /*==========================================set Country Code===================================*/

  setCountryCode(String countryCode,) {
    _form = state.formState.copyWith(countryCode: Field(value: countryCode));
    late Field code;
    code = _form.countryCode.copyWith(countryCode: countryCode);
    state = state.copyWith(formState: _form.copyWith(countryCode: code));
  }

  /*========================================check Email Field==================================*/

  checkEmailField(String email){
    _form = state.formState.copyWith(isEmailLogin: Field(value: email));
    late Field emailId;
    emailId = _form.countryCode.copyWith(isEmail: email);
    state = state.copyWith(formState: _form.copyWith(isEmailLogin: emailId));
  }

  /*=========================================set Text Filed Visibility===================================*/

  setTextFiledVisibility(String visibility) {
    _form = state.formState.copyWith(textFieldVisibility: Field(value: visibility));
    late Field field;
    if(visibility.toString() == 'true') {
     field = _form.textFieldVisibility.copyWith(textFieldVisibility: true);
     }
   else{
    field = _form.textFieldVisibility.copyWith(textFieldVisibility: false);
    }
    state = state.copyWith(formState: _form.copyWith(textFieldVisibility: field));
  }

}