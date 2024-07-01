import 'dart:async';
import 'dart:isolate';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/new_my_bike_list_screen.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/main.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';
import 'dart:developer';
import '../../../../constants/app_colors.dart';

class OTPScreen extends ConsumerStatefulWidget{
  const OTPScreen({super.key});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

final otpTimerProvider = StateProvider((ref) => 120,);

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  late Timer _resendOTPTimer;

  @override
  initState(){
    super.initState();
    _startOTPResendTimer();
  }

  void _startOTPResendTimer(){
    final otpTimerNotifier = ref.read(otpTimerProvider.notifier);
    _resendOTPTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(otpTimerNotifier.state != 0){
        otpTimerNotifier.state--;
      }else{
        timer.cancel();
      }
    });
  }

  @override
  dispose(){
    _resendOTPTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: (){
        ref.read(otpTimerProvider.notifier).state = 120;
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 50.h, left: 12.w, right: 12.w),
            decoration: BoxDecoration(color: whiteColor),
            child: bodyView(),
          ),
        ),
      ),
    );
  }

  Widget bodyView(){
    return SingleChildScrollView(
      child: Column(
        children: [
          30.ph,
          text(title: LocaleKeys.keyOTPVerify.tr(), fontWeight: FontWeight.w600, fontSize: 24.sp),
          10.ph,
          _OTPSentInfo(),
          30.ph,
          text(title: LocaleKeys.keyOTPSubHeading.tr(), color: formHelperTextColor, fontSize: 16.sp, fontWeight: FontWeight.w400),
          20.ph,
          _OTPForm(),
          8.ph,
          _OTPErrorText(),
          30.ph,
          _ResendOTPTimerButton()
        ],
      ),
    );
  }

  Widget _OTPSentInfo(){
    return Container(
      child: Consumer(
          builder: (context, ref, child){
            final visibility = ref.watch(authProvider).formState.textFieldVisibility.textFieldVisibility;
            final String message;
            if(visibility){
              final phoneNumber = ref.watch(authProvider).formState.phoneNumber.value;
              final countryCode = ref.watch(authProvider).formState.countryCode.countryCode;
              message = LocaleKeys.keyOTPHeading.tr() + "+$countryCode " + formatPhone(phoneNumber);
            }else{
              final emailAddress = ref.watch(authProvider).formState.isEmailLogin.isEmail;
              message = LocaleKeys.keyOTPHeading.tr() + formatEmail(emailAddress);
            }
            return text(
                title: message,
                fontWeight: FontWeight.w400,
                fontSize: 16.sp, color: formHelperTextColor,
                textAlign: TextAlign.center
            );
          }
      ),
    );
  }

  Widget _OTPForm(){
    return Consumer(
      builder: (context, ref, child) {
        final fieldIsComplete = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isColor));
        return Container(
          height: 48.h,
          padding : EdgeInsets.symmetric(horizontal: 14.w),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index){
                return Expanded(
                    child: OTPTextField(
                        formIsFilled: fieldIsComplete,
                        focusNode: _focusNodes[index],
                        controller: _controllers[index],
                        onChanged: (value){
                          if(value.length == 1 && index < 5) FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                          else if(value.length == 0 && index > 0) FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          ref.read(authProvider.notifier).setOtpFormColor('');
                          if(ref.read(authProvider.notifier).validateOtpField(_controllers)) {
                            _validateOTP();
                          }
                        }
                    )
                );
              }),
            ),
          ),
        );
      },
    );
  }

  _validateOTP() async {
    FocusScope.of(context).unfocus();
    CustomLoaderDialog.buildShowDialog(context);
    final String otp = _controllers.map((e) => e.text).join();
    bool? response = await ref.read(authProvider.notifier).validateOtp(otp: otp.trim());
    if (mounted)  Navigator.pop(CustomLoaderDialog.dialogContext);
    if(response == true){
      Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) => const MyBikeList()), (Route<dynamic> route) => false,);
      if(AppUtils.getBool(key: Constants.FIRST_TIME_INSTALL) == true){
        log('First Time login');
      }else{
        log('Not First Time login');
      }
    }
  }

  Widget _OTPErrorText(){
    return Consumer(
      builder: (context, ref, child) {
        final errorText = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.value));
        final errorIsVisible = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isErrorBox));
        return Visibility(
          visible: errorIsVisible,
          child: text(title: errorText, fontWeight: FontWeight.w400, fontSize: 12.sp, textAlign: TextAlign.center, color: errorTextColor),
        );
      },
    );
  }

  Widget _ResendOTPTimerButton(){
    log('Rebuilt');
    return Consumer(
        builder : (context, ref, child) {
          final secondsLeft = ref.watch(otpTimerProvider);
          if(secondsLeft != 0){
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(title: LocaleKeys.keyOTPNotReceived.tr(), color: formHelperTextColor, fontWeight: FontWeight.w400, fontSize: 14.sp),
                8.pw,
                text(title: "${formatSeconds(secondsLeft)}", color: greenColor, fontWeight: FontWeight.w400, fontSize: 14.sp)
              ],
            );
          }else{
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children : [
                text(title: LocaleKeys.keyOTPNotReceived.tr(), color: formHelperTextColor, fontWeight: FontWeight.w400, fontSize: 14.sp),
                4.pw,
                GestureDetector(
                  onTap: () async {
                    CustomLoaderDialog.buildShowDialog(context);
                    await ref.read(authProvider.notifier).resendOTP();
                    _controllers.forEach((controller) => controller.clear());
                    FocusScope.of(context).unfocus();
                    if (mounted)  Navigator.pop(CustomLoaderDialog.dialogContext);
                    ref.read(otpTimerProvider.notifier).state = 120;
                    _startOTPResendTimer();
                  },
                  child: Container(
                    child: text(title: LocaleKeys.keyResendOTP.tr(), color: blueTextButtonColor, fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ),
              ]
            );
          }
        },
    );
  }
}

String formatSeconds(int seconds){
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

String formatPhone(String phone){
  int index = 4;
  String numbersLeft = phone.substring(index);
  return "****" + numbersLeft;
}

String formatEmail(String email){
  List<String> splitAtString = email.split('@');
  final totalLength = splitAtString.first.length;
  String emailName = splitAtString.first.substring(0, totalLength - 4);
  final String emailDomain = splitAtString.last;
  return emailName + "****@" + emailDomain;
}