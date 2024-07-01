import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/gredient_border.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/strings.dart';

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(this.item1, this.item2);

}


/*============================================Text widget======================================*/
Widget text({
  String? title,
  Color? color,
  double? fontSize,
  int? maxLines,
  FontWeight? fontWeight,
  TextAlign? textAlign,
  TextOverflow? textOverflow = TextOverflow.ellipsis,
  bool? isItalic,
  TextDecoration? decoration,
  String? fontFamily
}) =>
    Text(
      title!,
      maxLines: maxLines ?? 2,
      textAlign: textAlign,
      style: TextStyle(
        decoration: decoration ?? TextDecoration.none,
        fontFamily: fontFamily ?? 'SourceSans3',
        fontWeight: fontWeight,
        color: color ?? headingBlackTextColor,
        fontSize: fontSize,
        fontStyle: isItalic != null ? FontStyle.italic : null
      ),
    );

/*===========================================Size box widget=====================================*/
extension EmptyPadding on num {
  SizedBox get ph => SizedBox(
        height: toDouble().h,
      );

  SizedBox get pw => SizedBox(
        width: toDouble().w,
      );
}
/*===========================================open map Widget======================================*/

Future<void> openMap({BuildContext? context, double? lat, double? lng}) async {
  String url = '';
  String urlAppleMaps = '';
  if (Platform.isAndroid) {
    url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot launch Google map';
    }
  } else {
    urlAppleMaps = 'https://maps.apple.com/?q=$lat,$lng';
    url = 'comgooglemaps://?saddr=&daddr=$lat,$lng&directionsmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
      await launchUrl(Uri.parse(urlAppleMaps), mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot launch Apple map';
    }
  }
}
/*==========================================open Distance Map Widget======================================*/

Future<void> openDistanceMap({BuildContext? context, double? startLat, double? startLng, double? endLat, double? endLng}) async {
  String url = '';
  String urlAppleMaps = '';
  if (Platform.isAndroid) {
    url = 'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&dirflg=d';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot launch Google map';
    }
  } else if (Platform.isIOS) {
    urlAppleMaps = 'https://maps.apple.com/?saddr=$startLat,$startLng&daddr=$endLat,$endLng&dirflg=d';
    url = 'comgooglemaps://?saddr=$startLat,$startLng&daddr=$endLat,$endLng&directionsmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
      await launchUrl(Uri.parse(urlAppleMaps), mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot launch Apple map';
    }
  } else {
    throw 'Maps are not supported on this platform.';
  }
}

/*==========================================buildErrorWidget=====================================*/

Widget buildErrorWidget(Object error) {
  return Center(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        height: 100.h,
      ),
      const Icon(
        Icons.error_outline,
        size: 34,
        color: Colors.red,
      ),
      SizedBox(
        height: 10.h,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: text(
            title: error.toString(), maxLines: 2, textAlign: TextAlign.center),
      ),
    ],
  ));
}
/*========================================text Form Field=====================================*/

Widget textFormField({TextEditingController? controller, String? hintText, int? maxLength ,onChanged , Widget? prefixIcon
  , EdgeInsets? contentPadding ,double? hintFontSize,TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters,
  bool autofocus = false, TextInputAction? textInputAction,bool readOnly = false,Widget? suffixIcon, Function? suffixOnTab,TextAlign? textAlign,
  BoxConstraints? suffixIconConstraints, bool hasError = false, double? formFieldHeight, FocusNode? focusNode, bool obscureText = false}) {

  return Container(
      width: double.infinity,
      height: formFieldHeight ?? 36.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: hasError ? errorTextColor : Color.fromRGBO(168, 168, 168, 1)),
      ),
      child: TextFormField(
        obscureText: obscureText,
        focusNode: focusNode,
        readOnly: readOnly,
        autofocus: autofocus,
        onChanged: onChanged,
        textAlign: textAlign ?? TextAlign.start,
        maxLength: maxLength,
        textInputAction: textInputAction ??TextInputAction.next,
        controller: controller,
        cursorColor: headingBlackTextColor,
        inputFormatters: inputFormatters??<TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        keyboardType:keyboardType?? const TextInputType.numberWithOptions(signed: true),
        style: TextStyle(
            fontSize: 16.0.sp,
            fontFamily: 'SourceSans3',
            color: headingBlackTextColor,
            fontWeight: FontWeight.w500
        ),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIconConstraints: suffixIconConstraints ,
          suffixIcon : suffixIcon ?? InkWell(
              onTap: (){
                if(suffixOnTab != null){
                  suffixOnTab();
                }
              },
              child: Padding(
                padding:  EdgeInsets.only(left: 15.0.h),
                child: Icon(Icons.highlight_remove_sharp ,size: 20.h, color: greyEsColor,),
              )),
          hintStyle: TextStyle(
              fontSize: hintFontSize ?? 16.0.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'SourceSans3',
              color: formHintTextColorForAuthScreens),
          contentPadding: contentPadding,
          counterText: '',
          border: InputBorder.none,
          hintText: hintText,
        ),
      ));
}

/*========================================OTP Form Field=====================================*/

Widget OTPTextField({required TextEditingController controller,required onChanged, EdgeInsets? margin, FocusNode? focusNode, bool formIsFilled = false}){
  return Consumer(
    builder : (context, ref, child) {
      final borderColor = ref.watch(authProvider.select((value) => value.formState.isErrorBoxShow.isErrorBox));
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor ? errorTextColor : (formIsFilled ? blueTextButtonColor : Color.fromRGBO(213, 212, 212, 1))),
        ),
        margin: margin ?? EdgeInsets.symmetric(horizontal: 3.w),
        child: TextFormField(
          focusNode: focusNode,
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(
              fontSize: 16.0.sp,
              fontFamily: 'SourceSans3',
              color: headingBlackTextColor,
              fontWeight: FontWeight.w400
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly
          ],
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              border: InputBorder.none
          ),
          onChanged: onChanged,
        ),
      );
    },
  );
}

/*========================================common button====================================*/

Widget commonButton({double? height, double? width, String? buttonText,Function? onTap , bool? isIconButton = false , Color textColor = whiteColor, String? buttonImage,
  List<Color>? buttonColor, FontWeight? fontWeight,bool? isLoader = false, double? fontSize, double? buttonSize, bool hasBorder = false, bool changeTextColor = false,
  String? textFont, Color? borderColor, Color? buttonTextColor}){
  return InkWell(
    onTap: (){
      if(onTap !=null){
        onTap();
      }
    },
    child: PhysicalModel(
      color: whiteColor,
      shadowColor: const Color.fromRGBO(111, 145, 178, 0.4),
      borderRadius: BorderRadius.circular(5.r),
      child: Container(
        height: height ?? 44.h,
        width: width ?? double.infinity,
         alignment: Alignment.center,
         decoration:  BoxDecoration(
             border: hasBorder ? Border.all(width: 1, color: borderColor ?? horizontalDividerColor) : Border(),
             borderRadius: BorderRadius.circular(8.r),
             gradient: LinearGradient(
             begin: Alignment.topCenter,
             end: Alignment.bottomCenter,
             colors:  buttonColor!
             )),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isIconButton == true? buttonImage == null ? Container() : Image.asset(buttonImage ,scale: buttonSize ?? 2.5.h,) : Container(),
            isIconButton == true?  10.pw : Container(),
            isLoader == true ? Container( alignment: Alignment.center,height: 20.h,width: 20.h,child: CircularProgressIndicator(strokeWidth: 3.h, color: whiteColor,))
                :text(
                fontFamily: textFont,
                title:buttonText,
                color: buttonTextColor ?? (isIconButton == true ? Color.fromRGBO(64, 64, 64, 1) : (changeTextColor ? whiteColor : commonButtonTextColor)),
                fontSize: isIconButton == true ? 14.sp : fontSize ?? 16.sp,
                fontWeight: fontWeight??FontWeight.w500,
            ),
          ],
        ),
      ),
    ),
  );
}

/*================================================= heading Text View===============================================*/
Widget headingText({List<Color>? gradientColor, String? title, double? fontSize, FontWeight? fontWeight}) {
  return ShaderMask(
    shaderCallback: (bounds) =>
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: gradientColor!,
        ).createShader(bounds),
    child: text(
        color: whiteColor,
        title: title,
        fontSize: fontSize ?? 20.sp,
        fontWeight: fontWeight ?? FontWeight.w500),
  );
}

/*================================================User Details View===============================================*/

Widget userDetailsView({String? name, String? phoneNumber, String? email, Widget? child, bool? isDivider = true,bool isIcon = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: text(
                title: name ?? '',
                color: blackColor,
                fontSize: 16.sp,
                maxLines: 1,
                fontWeight: FontWeight.w500),
          ),
          isIcon == false ? Container() : child!,
        ],
      ),
      2.ph,
      text(
          title: phoneNumber ?? '',
          color: blackColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.w400),
      2.ph,
      text(
          title: email ?? '',
          color: greyBoldColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.w400),
      5.ph,
      isDivider == false ? Container() : Divider(
        color: greyBoldColor,
        thickness: 0.5.h,
      ),
    ],
  );
}
/*=============================================================list Tile View===============================*/
Widget listTileView(
    {String? title,
      String? subTitle,
      Widget? trailingIcon,
      Widget? subTitleWidget,
      String? leadingIcons,
       padding ,
      leadingPadding,
      Function? onTap,
      Function? leadingOnTap,
      double? margin,
      double? leadingHeight,
      Color? subTitleColor}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: margin ?? 20.h),
    child: Row(
      children: [
        InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              if (leadingOnTap != null) {
                leadingOnTap();
              }
            },
            child: Image.asset(leadingIcons!, scale: leadingHeight ?? 2.5.h)),
        leadingPadding?? 15.pw,
        Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: (){
                if (leadingOnTap != null) {
                  leadingOnTap();
                }
              },
              child: text(
                  maxLines: 1,
                  title: title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: blackColor),
            )),
        InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (onTap != null) {
                onTap();
              }
            },
            child: subTitleWidget??text(
                title: subTitle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: subTitleColor??blackColor)),
        padding ?? 15.pw,
        InkWell(
          onTap: () {
            if (onTap != null) {
              onTap();
            }
          },
          child: trailingIcon ?? Image.asset(icDropDown, scale: 2.5.h),
        ),
      ],
    ),
  );
}

/*======================================App Common Dialog=============================================*/

void appCommonDialog({Function? onTap, context, String? title, String? descriptionText,bool? longDesc}) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(  borderRadius: BorderRadius.circular(15.r)),
          backgroundColor: whiteColor,
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 25.w,vertical: 25.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                text(title: title ?? LocaleKeys.keyLogout.tr(),fontSize: 18.sp,fontWeight: FontWeight.w700 ),
                10.ph,
                Flexible(
                  child: text(
                      title: descriptionText?? LocaleKeys.keyLogoutDes.tr(),fontSize: 14.sp,fontWeight: FontWeight.w500 ,
                      textAlign: longDesc != null ? TextAlign.left : TextAlign.center,maxLines: longDesc != null ? 15 : 2),
                ),
                longDesc != null ? 30.ph : 15.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
                        width: 80.w,
                        decoration: BoxDecoration(color: blueColor,borderRadius: BorderRadius.circular(5.r)),
                        child: text(title: LocaleKeys.keyNo.tr(),fontSize: 16.sp,fontWeight: FontWeight.w700 , color: whiteColor),
                      ),
                    ),
                    20.pw,
                    GestureDetector(
                      onTap: () {
                        if(onTap != null){
                          onTap();
                        }
                      },
                      child:  Container(
                        width: 80.w,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
                        decoration: BoxDecoration(color: blueColor,
                            borderRadius: BorderRadius.circular(5.r)
                        ),
                        child: text(title: LocaleKeys.keyYes.tr(),fontSize: 16.sp,fontWeight: FontWeight.w700 , color: whiteColor),
                      ),
                    ),
                    SizedBox(
                      width: 10.0.w,
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}

void checkAppUpdate(BuildContext context,MethodChannel platform)async {
  //TODO UNDO THIS WHILE TESTING WITH ANDROID
  if(!kDebugMode){
    bool isUpdateAvailable = await platform.invokeMethod(Constants.CHECK_APP_UPDATE,'');
    log('updateStatus $isUpdateAvailable');
    if(Platform.isIOS){
      print('isUpdateAvailable $isUpdateAvailable}');
      if(isUpdateAvailable){
        appCommonDialog(
          context: context,
          title: LocaleKeys.keyUpdateAvailableTitle.tr(),
          descriptionText: LocaleKeys.keyUpdateAvailableText.tr(),
          longDesc: true,
          onTap: () async {
            Navigator.pop(context);
            await platform.invokeMethod(Constants.OPEN_APP_STORE,'');
          },
        );
      }
    }
  }
}
