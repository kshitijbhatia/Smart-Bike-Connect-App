import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';

void showToast(String message,{bool? centerGravity,bool? warning,bool? duration,bool? generic}){
  Fluttertoast.showToast(
    msg: message,
    toastLength: duration != null ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    gravity: centerGravity != null ? ToastGravity.CENTER : ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: warning != null ? warning ? errorColor : Colors.greenAccent : generic != null ? greyBoldColor : const Color(0xFF23252A),
    textColor: warning != null ? warning ? whiteColor : generic != null ? whiteColor : Colors.black : whiteColor,
    fontSize: 14.sp,
  );

}