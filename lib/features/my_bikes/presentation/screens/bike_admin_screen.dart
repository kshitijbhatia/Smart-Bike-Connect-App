import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/bike_admin_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/bottom_nav_bar.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/scanner_screen.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';

class VehicleAdminScreen extends ConsumerStatefulWidget {
  const VehicleAdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VehicleAdminScreen> createState() => _VehicleAdminScreenState();
}

class _VehicleAdminScreenState extends ConsumerState<VehicleAdminScreen> {

  TextEditingController textController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Container(child: _bodyView(),);
  }
  /*=======================================================scan QR View===============================*/

  Widget _bodyView() {
    return Container(
       alignment: Alignment.center,
       width: MediaQuery.of(context).size.width,
       height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            text(title: LocaleKeys.keySearchBy.tr(),fontSize: 16.sp, fontWeight: FontWeight.w800),
            10.ph,
            Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final bikeAdmin = ref.watch(bikeAdminController.notifier);
              return textFormField(
                textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  controller: textController,
                  textInputAction: TextInputAction.done,
                  contentPadding: EdgeInsets.only( left:5.h,right:5.h,bottom: 10.h,top: 10.h),
                  suffixIcon: Container(width: 0.0,),
                 suffixIconConstraints:  BoxConstraints(maxWidth: 0.0),
                  onChanged: (value){
                    bikeAdmin.setErrorBox(false);
                    if(value.toString().trim().length > 0){
                      bikeAdmin.setButtonColor(true);
                    }else{
                      bikeAdmin.setButtonColor(false);
                    }
                  },
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_ -]+$')),
                  ],
                  hintText: LocaleKeys.keyEnterSBMId.tr(),
                  maxLength: 50);
            },

            ),
            15.ph,
            _submitButton(),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final visibility =  ref.watch(bikeAdminController.select((value) => value.isErrorBox));
                return Visibility(
                  visible: visibility,
                  child: Padding(
                    padding:  EdgeInsets.only(top: 8.0.h),
                    child: errorWidget(subTitle: LocaleKeys.keyScannedId.tr(), ),
                  ),
                );
              },
            ),
            15.ph,
            _dividerView(),
            15.ph,
            Consumer(

              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final bikeAdmin = ref.watch(bikeAdminController.notifier);
                return commonButton(
                    buttonText: LocaleKeys.keyScanQR.tr(),
                    textColor: buttonTextColor,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      textController.clear();
                      bikeAdmin.setButtonColor(false);
                      bikeAdmin.setErrorBox(false);
                      _requestCameraPermissionThenNavigate();
                      //Navigator.push(this.context, MaterialPageRoute(builder: (context) =>  ScannerScreen(isAdmin: true,)));
                    },
                    buttonColor: [
                      whiteColor,
                      whiteColor,
                    ]);

              },

            ),
            15.ph,
          ],
        ),
      ),
    );
  }
  /*=========================================submit Button================================*/

  Widget _submitButton(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final bikeAdmin = ref.watch(bikeAdminController.notifier);
        final buttonColor = ref.watch(bikeAdminController.select((value) => value.buttonColor));
        return commonButton(
          onTap: buttonColor == false ?(){}:() async {
            FocusScope.of(context).requestFocus(FocusNode());
            CustomLoaderDialog.buildShowDialog(context);
            var response =  await  bikeAdmin.searchSBM(textController.text.trim());
            if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
            if(response != null){
              await  AppUtils.setString(key:Constants.SELECTED_BIKE_META, value : json.encode(response[0]));
              Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) =>
                  BottomNavBar(bikeData : response[0], isStartService: true)), (Route<dynamic> route) => false);
              bikeAdmin.setErrorBox(false);
              bikeAdmin.setButtonColor(false);
            }
          },
          buttonColor: buttonColor == true ? [const Color.fromRGBO(47, 64, 126, 1.0), const Color.fromRGBO(109, 69, 194, 1.0)] :[Colors.grey, Colors.grey],
          buttonText: LocaleKeys.keySubmit.tr(),
        );

      },
    );
  }

  /*==========================================divider View====================================*/

  Widget _dividerView() {
    return Row(
      children: [
        Expanded(
            child: Divider(
              color: dividerColor,
              thickness: 1.h,
            )),
        8.pw,
        text(
            title: LocaleKeys.keyOr.tr(),
            color: dividerColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500),
        8.pw,
        Expanded(child: Divider(color: dividerColor, thickness: 1.h))
      ],
    );
  }

  void _requestCameraPermissionThenNavigate() async {

    bool _isCameraPerm = await Permission.camera.isGranted;

    if ( !_isCameraPerm) {
      await Permission.camera.request();
      if (await Permission.camera.isGranted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  ScannerScreen(isAdmin: true)));
      } else {
        appCommonDialog(
            context: context,
            title: LocaleKeys.keyPermTitle.tr(),
            descriptionText: LocaleKeys.keyCameraPerm.tr(),
            longDesc: true,
            onTap: () async {
            Navigator.pop(context);
            await openAppSettings();
          },
        );
      }
    }else{
      Navigator.push(context, MaterialPageRoute(builder: (context) =>  ScannerScreen(isAdmin: true)));
    }
  }
}

