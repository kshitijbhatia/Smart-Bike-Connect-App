import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/main.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';

class CreatePinScreen extends StatefulWidget{
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {

  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _confirmPinFocusNode = FocusNode();

  @override
  dispose(){
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
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
          child: _bodyView(),
        ),
      ),
    );
  }

  Widget _bodyView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                10.ph,
                Container(child: Image.asset(icTVSLogo ,width:150.w,height: 50.h,),),
                50.ph,
                text(title: LocaleKeys.keySetNewPinHeading.tr(), fontSize: 24.sp, fontWeight: FontWeight.w600,),
                10.ph,
                text(title : LocaleKeys.keySetNewPinSubHeading.tr(), fontSize: 16.sp, fontWeight: FontWeight.w400, color: formHelperTextColor),
                35.ph,
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 6.h),
                  child: text(title : LocaleKeys.keyNewPinText.tr(), fontSize: 14.sp, fontWeight: FontWeight.w400, color: Color.fromRGBO(125, 125, 125, 1), textAlign: TextAlign.left),
                ),
                _newPinTextField(),
                15.ph,
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 6.h),
                  child: text(title : LocaleKeys.keyConfirmPinText.tr(), fontSize: 14.sp, fontWeight: FontWeight.w400, color: Color.fromRGBO(125, 125, 125, 1)),
                ),
                _confirmNewPinField(),
                10.ph,
                Consumer(
                  builder: (context, ref, child) {
                    final error = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.value));
                    return Visibility(
                      visible: error.isNotEmpty,
                      child: Container(
                        width: double.infinity,
                        child: text(title: error, fontSize: 14.sp, fontWeight: FontWeight.w400, color: errorTextColor, textAlign: TextAlign.left)
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        _createPinButton(),
      ],
    );
  }

  Widget _newPinTextField(){
    return Consumer(
      builder : (context, ref, child) {
        return textFormField(
            focusNode: _pinFocusNode,
            hintText: LocaleKeys.keyNewPinTextField.tr(),
            hintFontSize: 16.sp,
            controller: _pinController,
            contentPadding: EdgeInsets.only(top: 3.h, left: 12.w),
            obscureText: false,
            suffixIcon: Container(width: 0.w, height : 0.h,),
            inputFormatters: [
              LengthLimitingTextInputFormatter(4),
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            onChanged: (value){
              if(value.length == 4) FocusScope.of(context).requestFocus(_confirmPinFocusNode);
              ref.read(authProvider.notifier).setCreatePinButtonColor(_pinController.text, _confirmPinController.text);
            },
            textInputAction : TextInputAction.done,
        );
      },
    );
  }

  Widget _confirmNewPinField(){
    return Consumer(
      builder: (context, ref, child) {
        final error = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.value));
        return textFormField(
            hasError: error.isNotEmpty,
            focusNode: _confirmPinFocusNode,
            hintText: LocaleKeys.keyConfirmPinText.tr(),
            hintFontSize: 16.sp,
            controller: _confirmPinController,
            contentPadding: EdgeInsets.only(top: 3.h, left: 12.w),
            obscureText: true,
            suffixIcon: Container(width: 0.w, height : 0.h,),
            inputFormatters: [
              LengthLimitingTextInputFormatter(4),
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            onChanged: (value){
              if(value.length == 4) FocusScope.of(context).unfocus();
              ref.read(authProvider.notifier).setCreatePinButtonColor(_pinController.text, _confirmPinController.text);
            },
            textInputAction : TextInputAction.done,
        );
      },
    );
  }

  Widget _createPinButton(){
    return Consumer(
      builder:  (context, ref, child) {
        final visibility = ref.watch(authProvider).formState.isErrorBoxShow.isColor;
        final hasFocus = FocusScope.of(context).hasFocus;
        return Container(
          margin: EdgeInsets.only(bottom: hasFocus ? MediaQuery.of(context).viewInsets.bottom + 20.h : 20.h),
          child: commonButton(
              width: double.infinity,
              height: 40.h,
              buttonText: LocaleKeys.keyCreatePin.tr(),
              buttonColor: visibility ? [blueTextButtonColor, blueTextButtonColor]  : [commonButtonDisabledColor, commonButtonDisabledColor],
              buttonTextColor: visibility ? whiteColor : formHintTextColor,
              onTap: (){
                if(_pinController.text != _confirmPinController.text){
                  ref.read(authProvider.notifier).setCreatePinButtonColor(_pinController.text, _confirmPinController.text, error: "Sorry! The pin does not match. Please re-enter the pin carefully");
                  return;
                }
                final String pin = _pinController.text;
                log('Pin: $pin');
              }
          ),
        );
      },
    );
  }
}