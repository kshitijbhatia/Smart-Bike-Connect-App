
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/circular_progress_indicatior.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';

class CustomLoaderDialog{
  static  late BuildContext _dialogContext;


 static BuildContext get dialogContext => _dialogContext;

  static  buildShowDialog(BuildContext context ,{title}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dContext) {
          _dialogContext = dContext;
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 50.0.w),
                  child: Container(
                      width: double.infinity,
                      height: title != null ? title.toString().length > 50 ? 165.h : 120.0.h : 120.h,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0.w,vertical: 10.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            10.ph,
                            const ProgressIndicatorView(),
                            10.ph,
                            Expanded(
                              child: text(title: "${ title ?? LocaleKeys.keyLoading.tr()}",
                                fontSize: title != null ? 14.sp : 16.0.sp,
                                color: blueColor,
                                maxLines: title != null ? 3 : 1 ,
                                fontWeight: FontWeight.w700,
                                textAlign: TextAlign.center
                              ),
                            ),

                          ],
                        ),
                      )),
                )),
          );
        });
  }
}
/*===========================================error Widget======================================*/

Widget errorWidget({String? subTitle}){
  String errorMessage;
  if(subTitle == null){
    errorMessage = LocaleKeys.keySorry.tr() + LocaleKeys.keyLoginErrorMsg.tr();
  }else{
    errorMessage = LocaleKeys.keySorry.tr() + subTitle;
  }
  return Container(
    padding:  EdgeInsets.only(right: 10.w, top: 5.h),
    child: text(title: errorMessage, color: errorTextColor, fontWeight: FontWeight.w400, fontSize: 12.sp,)
  );
}