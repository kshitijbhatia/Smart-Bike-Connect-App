import 'dart:async';
import 'dart:isolate';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:smartbike_flutter/features/authentication/presentation/screens/new_login_screen.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/new_my_bike_list_screen.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';
import 'dart:developer' as developer;
import '../../../../constants/app_colors.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;





Uint8List generateRandomBytes(int length) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return Uint8List.fromList(bytes);
}

String encrypt(String plaintext) {
  final key = generateRandomBytes(32);  // 256-bit key
  final iv = generateRandomBytes(16);  // 128-bit IV

  final cipher = pc.GCMBlockCipher(pc.AESFastEngine())
    ..init(true, pc.AEADParameters(pc.KeyParameter(key), 128, iv, Uint8List(0)));

  final input = Uint8List.fromList(utf8.encode(plaintext));
  final output = cipher.process(input);

  final encrypted_pin = Uint8List.fromList([...output, ...key, ...iv]);
  String encoded_pin = base64.encode(encrypted_pin);

  return encoded_pin;
}



String decrypt(String encoded_pin) {
  final decoded_pin = base64.decode(encoded_pin);

  final keySize = 32;
  final ivSize = 16;
  final cipherTextSize = decoded_pin.length - keySize - ivSize;

  final cipherText = Uint8List.sublistView(decoded_pin, 0, cipherTextSize);
  final key = Uint8List.sublistView(decoded_pin, cipherTextSize, cipherTextSize + keySize);
  final iv = Uint8List.sublistView(decoded_pin, cipherTextSize + keySize, cipherTextSize + keySize + ivSize);


  final cipher = pc.GCMBlockCipher(pc.AESFastEngine())
    ..init(false, pc.AEADParameters(pc.KeyParameter(key), 128, iv, Uint8List(0)));

  final output = cipher.process(cipherText);
  return utf8.decode(output);
}





class EnterPinScreen extends ConsumerStatefulWidget{
  const EnterPinScreen({super.key});

  @override
  ConsumerState<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends ConsumerState<EnterPinScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  initState(){
    super.initState();
  }

  @override
  dispose(){
    _controllers.map((controller) => controller.dispose());
    _focusNodes.map((focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 50.h, left: 12.w, right: 12.w,),
            decoration: BoxDecoration(color: whiteColor),
            child: bodyView(),
          ),
        ),
      ),
    );
  }

  Widget bodyView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Column(
            children: [
              Container(child: Image.asset(icTVSLogo ,width:150.w,height: 50.h,),),
              50.ph,
              text(title: LocaleKeys.keyEnterPinHeading.tr(), fontWeight: FontWeight.w600, fontSize: 24.sp),
              5.ph,
              text(title: LocaleKeys.keyEnterPinSubHeading.tr(), fontWeight: FontWeight.w400, fontSize: 16.sp, color: formHelperTextColor),
              40.ph,
              _OTPForm(),
              8.ph,
              _OTPErrorText(),
              40.ph,
              _forgotPinSection(),
            ],
          ),
        ),
        _loginButton(),
      ],
    );
  }

  Widget _OTPForm(){
    return Container(
      height: 48.h,
      padding : EdgeInsets.symmetric(horizontal: 50.w),
      child: Form(
        key: _formKey,
        child: Consumer(
          builder : (context, ref, child) {
            final formIsFilled = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isColor));
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index){
                return Expanded(
                    child: OTPTextField(
                        formIsFilled: formIsFilled,
                        focusNode: _focusNodes[index],
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        controller: _controllers[index],
                        onChanged: (value){
                          if(value.length == 1){
                            if(index < 3) FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                            else FocusScope.of(context).unfocus();
                          }else if(value.length == 0 && index > 0) FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          ref.read(authProvider.notifier).setEnterPinButtonColor(_controllers);
                        }
                    )
                );
              }),
            );
          },
        ),
      ),
    );
  }

  _validatePin() async {
    FocusScope.of(context).unfocus();
    // CustomLoaderDialog.buildShowDialog(context);
    final String pin = _controllers.map((e) => e.text).join();
    developer.log('Pin: $pin');

    String encoded_pin = encrypt(pin);
    developer.log('Encoded:' + encoded_pin);
    final decrypted = decrypt(encoded_pin);
    developer.log("Decrypted: $decrypted");
    // bool? response = await ref.read(authProvider.notifier).validateOtp(otp: otp.trim());
    // if (mounted)  Navigator.pop(CustomLoaderDialog.dialogContext);
    // if(response == true) Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) => const MyBikeList()), (Route<dynamic> route) => false,);
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

  Widget _forgotPinSection(){
    return Container(
      child: Column(
        children: [
          text(title: LocaleKeys.keyForgotPinText.tr(), fontWeight: FontWeight.w400, fontSize: 14.sp, color: formHelperTextColor),
          3.ph,
          GestureDetector(
            onTap: (){
              // TODO
              // Remove the key from shared preference
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
            },
            child: text(title: LocaleKeys.keyForgotPin.tr(), fontWeight: FontWeight.w600, fontSize: 14.sp, color: blueTextButtonColor),
          ),
        ],
      ),
    );
  }

  Widget _loginButton(){
    return Consumer(
      builder: (context, ref, child) {
        final fieldIsComplete = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isColor));
        final hasFocus = FocusScope.of(context).hasFocus;
        return Container(
          margin: EdgeInsets.only(bottom: hasFocus ? MediaQuery.of(context).viewInsets.bottom + 20.h : 20.h),
          child: commonButton(
              width: double.infinity,
              height: 42.h,
              buttonText: LocaleKeys.keyLogin.tr(),
              buttonColor: fieldIsComplete ? [blueTextButtonColor, blueTextButtonColor] : [commonButtonDisabledColor, commonButtonDisabledColor],
              onTap: _validatePin,
              changeTextColor: fieldIsComplete
          ),
        );
      },
    );
  }
}
