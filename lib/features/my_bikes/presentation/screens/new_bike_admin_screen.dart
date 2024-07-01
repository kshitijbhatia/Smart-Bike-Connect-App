import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/bike_admin_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/bottom_nav_bar.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/new_scanner_screen.dart';
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
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
            child: _bodyView(),
        ),
      ),
    );
  }

  /*=======================================================scan QR View===============================*/

  Widget _bodyView() {
    return Container(
      color: whiteColor,
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: EdgeInsets.only(top: 50.h, left : 15.w, right: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(child: Image.asset(icTVSLogo ,width:150.w,height: 50.h,),),
            60.ph,
            text(title: LocaleKeys.keySearchBy.tr(),fontSize: 22.sp, fontWeight: FontWeight.w600),
            35.ph,
            _vehicleSBMIDTextFormField(),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final visibility =  ref.watch(bikeAdminController.select((value) => value.isErrorBox));
                return Visibility(
                  visible: visibility,
                  child: Container(
                    padding:  EdgeInsets.only(top: 6.0.h),
                    width: double.infinity,
                    child: text(title : LocaleKeys.keyScannedId.tr(), fontWeight: FontWeight.w400, fontSize: 12.sp, color: errorTextColor, textAlign: TextAlign.left),
                  ),
                );
              },
            ),
            20.ph,
            _submitButton(),
            30.ph,
            _dividerView(),
            30.ph,
            _scanQRCodeButton(),
            // Container(height: 100.h, color: Colors.red,)
          ],
        ),
      ),
    );
  }

  /*=========================================Vehicle & SBM ID Text Form Field================================*/

  Widget _vehicleSBMIDTextFormField(){
    return Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final bikeAdmin = ref.watch(bikeAdminController.notifier);
      final visibility =  ref.watch(bikeAdminController.select((value) => value.isErrorBox));
      return textFormField(
        hasError: visibility,
        keyboardType: TextInputType.text,
        controller: textController,
        textInputAction: TextInputAction.done,
        contentPadding: EdgeInsets.only(left: 12.w, top: 4.h),
        suffixIcon: Container(width: 0.0.w,),
        suffixIconConstraints:  BoxConstraints(maxWidth: 0.0.w),
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
        maxLength: 50,
      );
    },);
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
          buttonColor: buttonColor == true ? [blueTextButtonColor, blueTextButtonColor] :[commonButtonDisabledColor, commonButtonDisabledColor],
          buttonText: LocaleKeys.keySubmit.tr(),
          changeTextColor: buttonColor,
        );
      },
    );
  }

  /*==========================================divider View====================================*/

  Widget _dividerView() {
    return Row(
      children: [
        Expanded(child: Divider(color: horizontalDividerColor, thickness: 1.h,)),
        8.pw,
        text(title: LocaleKeys.keyOr.tr(), color: horizontalDividerTextColor, fontFamily: "Nunito", fontSize: 14.sp, fontWeight: FontWeight.w500),
        8.pw,
        Expanded(child: Divider(color: horizontalDividerColor, thickness: 1.h))
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

/*========================================== Scan QR Code Button ====================================*/

  Widget _scanQRCodeButton(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final bikeAdmin = ref.watch(bikeAdminController.notifier);
        return commonButton(
            isIconButton: true,
            hasBorder: true,
            buttonImage: icScanner,
            buttonSize: 3.h,
            buttonText: LocaleKeys.keyScanQR.tr(),
            textFont: "Nunito",
            fontWeight: FontWeight.w600,
            textColor: buttonTextColor,
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              textController.clear();
              bikeAdmin.setButtonColor(false);
              bikeAdmin.setErrorBox(false);
              _requestCameraPermissionThenNavigate();
            },
            buttonColor: [
              whiteColor,
              whiteColor,
            ]);
      },
    );
  }
}