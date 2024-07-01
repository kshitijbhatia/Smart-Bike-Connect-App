import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/my_bike_list_screen.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';

import '../../../../widgets/toast.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {

  TextEditingController otpController = TextEditingController();

  late Timer _resendOTPTimer;
  int _count = 60;

  @override
  void initState() {
    super.initState();
    _startResendOTPTimer();
  }

  void _startResendOTPTimer() {
    _count = 120;
    _resendOTPTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_count > 0) {
        _count--;
      } else {
        timer.cancel();
        ref.read(authProvider.notifier).setResendOTPButtonColor(true);
        _count = 120;
        showToast(LocaleKeys.toastResendOTP.tr(),warning: true,duration: true);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _backButtonAction,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 50.h, bottom: 5.h, left: 30.w, right: 30.w),
            decoration:  const BoxDecoration(
                image: DecorationImage(image: AssetImage(authBg), fit: BoxFit.fitWidth)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headingView(),
                  20.ph,
                  text(title:LocaleKeys.keyOTPHeading.tr(), fontWeight: FontWeight.w800,color:buttonTextColor,fontSize: 16.sp ),
                  20.ph,
                  _textFormFieldView(),
                  20.ph,
                  _loginButton(),
                  100.ph,
                  Align(
                    alignment: Alignment.center,
                    child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: Transform.scale(
                          scale: 1.4.h,
                          child: SvgPicture.asset(
                             height: MediaQuery.of(context).size.height / 3.5,
                            'assets/images/ic_login_bike.svg',
                          ),
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  /*========================================text Form Field View=================================*/

  _textFormFieldView(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        Color buttonTxtColor = ref.watch(authProvider.select((value) => value.formState.resendOTPButtonTextColor));
        return textFormField(
          contentPadding: EdgeInsets.all(
            10.h,
          ),
          textInputAction: TextInputAction.done,
          suffixIcon: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 70.w,
              decoration: BoxDecoration(
                color: ref.watch(authProvider.select((value) => value.formState.resendOTPButtonColor)),
                borderRadius: BorderRadius.circular(5.r),
              ),
              margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
              child: Align(
                  alignment: Alignment.center,
                  child: text(title: LocaleKeys.keyResendOTP.tr(), color: buttonTxtColor, fontWeight: FontWeight.bold)),
            ),
            onTap: () async{
              if(buttonTxtColor == buttonTextColor){
                ref.read(authProvider.notifier).setResendOTPButtonColor(false);
                FocusScope.of(context).requestFocus(FocusNode());
                CustomLoaderDialog.buildShowDialog(context);
                await ref.read(authProvider.notifier).resendOTP();
                if (mounted)  Navigator.pop(CustomLoaderDialog.dialogContext);
                _startResendOTPTimer();
              }
            },
          ),
          onChanged: (value) {
            ref.watch(authProvider.notifier).setLoginButtonColor(value);
          },
          hintText: LocaleKeys.keyPhoneOtp.tr(),
          controller: otpController,
          maxLength: 6,
        );
      },
    );
  }

  /*======================================login Button=================================*/

  _loginButton() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return commonButton(
          buttonColor: ref.watch(authProvider.select((value) => value.formState.otp.buttonColor)),
          buttonText: LocaleKeys.keyLogin.tr(),
          onTap: ref.watch(authProvider.select((value) => value.formState.otp.isColor == false)) ? () {} : () async {
                  _onTapOfLoginButton();
                },
        );
      },
    );
  }
  /*========================================heading View====================================*/

  _onTapOfLoginButton() async{
    FocusScope.of(context).requestFocus(FocusNode());
    CustomLoaderDialog.buildShowDialog(context);
    bool? response = await ref.read(authProvider.notifier).validateOtp(otp: otpController.text.trim());
    if (mounted)  Navigator.pop(CustomLoaderDialog.dialogContext);
    if(response == true){
      Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) => const MyBikeList()), (Route<dynamic> route) => false,);
    }
  }

  Widget _headingView(){
    return  Row(children: [
      Image.asset(icLogo,scale: 2.6.h,),
      10.pw,
      ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromRGBO(47, 64, 126, 1.0), Color.fromRGBO(109, 69, 194, 1.0)],
        ).createShader(bounds),
        child: text(
            color: whiteColor,
            title: 'SBMConnect',
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            isItalic: true,
        ),
      ),
    ],);
  }

  Future<bool> _backButtonAction() async{
    ref.read(authProvider.notifier).setResendOTPButtonColor(false);
    return true;
  }


  @override
  void dispose() {
    _resendOTPTimer.cancel();
    super.dispose();
  }
}
