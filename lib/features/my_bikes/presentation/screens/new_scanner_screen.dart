import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/bike_admin_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/bottom_nav_bar.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';


class ScannerScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  ScannerScreen({this.isAdmin = false});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  MobileScannerController? controller = MobileScannerController();


  @override
  void initState() {
    super.initState();
  }

  Future<void> _onDetect(BarcodeCapture barcodeCapture) async {
    ref.read(bikeAdminController.notifier).setBarcodeCapture(barcodeCapture);
    ref.read(bikeAdminController.notifier).setBarcodeData(barcodeCapture.barcodes.first);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.1),
      body: _bodyView() ,
    );
  }

/*==============================================body View=====================================================*/

  Widget _bodyView(){
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero + Offset(0, - 40.h)),
      width: 200.h,
      height: 200.h,
    );
    return Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
      MobileScannerArguments? mobileScannerArguments = ref.watch(bikeAdminController.select((value) => value.mobileScannerArguments));
      Barcode? barcode = ref.watch(bikeAdminController.select((value) => value.barcode));
      BarcodeCapture? capture = ref.watch(bikeAdminController.select((value) => value.capture));
      final bikeAdmin = ref.watch(bikeAdminController.notifier);
      return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          MobileScanner(
            fit: BoxFit.fill,
            scanWindow: scanWindow,
            controller: controller,
            onScannerStarted: (arguments) {
              ref.watch(bikeAdminController.notifier).setMobileScannerArguments(arguments);
            },
            onDetect: _onDetect,
          ),
          if (barcode != null && barcode.corners != null && mobileScannerArguments != null)
            CustomPaint(
              painter: BarcodeOverlay(
                barcode: barcode,
                arguments: mobileScannerArguments,
                boxFit: BoxFit.contain,
                capture: capture!,
              ),
            ),
          CustomPaint(
            painter: ScannerOverlay(scanWindow),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 90.h,
              padding: EdgeInsets.only(top: 50.h,left: 20.w,right: 20.w),
              color: whiteColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: (){
                        bikeAdmin.setErrorBox(false);
                        controller?.stop();
                        bikeAdmin.setBarcodeData(null);
                        Navigator.pop(context);
                      },
                      child: Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Icon(Icons.arrow_back_ios_new_sharp, color: Color.fromRGBO(25, 25, 25, 1), size: 20.w,)
                      ),
                  ),
                  20.pw,
                  Expanded(child: text(title: LocaleKeys.keyScanVehicle.tr(),textAlign: TextAlign.center,
                      color: Color.fromRGBO(49, 49, 49, 1),fontSize: 18.sp,fontWeight: FontWeight.w700)),
                  30.pw,
                ],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(child: Container()),
              GestureDetector(
                onTap: () => controller!.toggleTorch(),
                child: Container(
                  width: 44.w,
                  height: 40.h,
                  padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 6.h, bottom: 3.h),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4.0,
                        spreadRadius: 2.0,
                        offset: Offset(2.0.w, 2.0.h),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Image.asset(icFlashLight ,color: Color.fromRGBO(84, 84, 84, 1),),
                ),
              ),
              20.ph,
              Consumer(
                builder: (context, ref, child) {
                  Barcode? barcode = ref.watch(bikeAdminController.select((value) => value.barcode));
                  if(barcode != null){
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 180.h,
                        child: _scannedDetailView(),
                        decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r))
                        ),
                      ),
                    );
                  }else{
                    return Container(height: 180.h,);
                  }
                },
              ),
            ],
          ),
        ],
      );
    },);
  }
/*================================================scanned Detail View=======================================================*/

  Widget _scannedDetailView(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        Barcode? barcode = ref.watch(bikeAdminController.select((value) => value.barcode));
        return Container(
          padding:  EdgeInsets.symmetric(horizontal: 15.w,vertical: 0.h),
          child: Column(
            children: [
              20.ph,
              Visibility(
                  visible: barcode?.displayValue != null ,
                  child: text(title: LocaleKeys.keyInfo.tr(),color: blackColor,fontSize: 18.sp,fontWeight: FontWeight.w600, textAlign: TextAlign.center),
              ),
              5.ph,
              Visibility(
                  visible: barcode?.displayValue != null ,
                  child: text(title: "${barcode?.displayValue}",color: formHelperTextColor,fontSize: 16.sp,fontWeight: FontWeight.w400, textAlign: TextAlign.center),
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final visibility =  ref.watch(bikeAdminController.select((value) => value.isErrorBox));
                  return Visibility(
                    visible: visibility,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.h),
                      child: errorWidget(subTitle: LocaleKeys.keyScannedId.tr(),),
                    ),
                  );
                },
              ),
              Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [_cancelButton(), _submitButton()],
                    ),
                  )
              )
            ],),
        );
      },
    );

  }

/*================================================cancel Button=======================================================*/

  Widget _cancelButton(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        Barcode? barcode = ref.watch(bikeAdminController.select((value) => value.barcode));
        return Visibility(
          visible: barcode?.displayValue != null,
          child: commonButton(
            width: 150.w,
            height: 42.h,
            onTap: () {
              ref.watch(bikeAdminController.notifier).setErrorBox(false);
              ref.watch(bikeAdminController.notifier).setBarcodeData(null);
            },
            buttonColor: [whiteColor, whiteColor],
            hasBorder: true,
            borderColor: blueTextButtonColor,
            buttonTextColor: blueTextButtonColor,
            buttonText: LocaleKeys.keyCancel.tr(),
            fontWeight: FontWeight.w600,
            fontSize: 14.sp
          ),
        );
      },
    );
  }

/*================================================submit Button=======================================================*/

  Widget _submitButton(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        Barcode? barcode = ref.watch(bikeAdminController.select((value) => value.barcode));
        final bikeAdmin = ref.watch(bikeAdminController.notifier);
        final hasError =  ref.watch(bikeAdminController.select((value) => value.isErrorBox));
        return Visibility(
          visible: barcode?.displayValue != null,
          child: commonButton(
            width: 150.w,
            height: 42.h,
            onTap: hasError ? (){} : () async {
              if(widget.isAdmin == true){
                CustomLoaderDialog.buildShowDialog(context);
                var response =  await  bikeAdmin.searchSBM(barcode!.displayValue!.trim());
                if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                if(response != null){
                  await  AppUtils.setString(key:Constants.SELECTED_BIKE_META, value : json.encode(response[0]));
                  Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) =>
                      BottomNavBar(bikeData : response[0], isStartService: true)), (Route<dynamic> route) => false);
                  bikeAdmin.setErrorBox(false);
                  bikeAdmin.setBarcodeData(null);
                }
              }
              else{
                bikeAdmin.setButtonColor(true);
                bikeAdmin.setBarcodeData(null);
                Navigator.pop(context,barcode!.displayValue!);
              }
            },
            buttonColor: hasError ? [commonButtonDisabledColor, commonButtonDisabledColor] : [blueTextButtonColor, blueTextButtonColor],
            buttonTextColor: hasError ? commonButtonTextColor : whiteColor,
            buttonText: LocaleKeys.keySubmit.tr(),
            // changeTextColor: hasError,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller!.stop();
  }
}



// for scan overlay
class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcode,
    required this.arguments,
    required this.boxFit,
    required this.capture,
  });

  final BarcodeCapture capture;
  final Barcode barcode;
  final MobileScannerArguments arguments;
  final BoxFit boxFit;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcode.corners == null) return;
    final adjustedSize = applyBoxFit(boxFit, arguments.size, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final ratioWidth =
        (Platform.isIOS ? capture.width! : arguments.size.width) /
            adjustedSize.destination.width;
    final ratioHeight =
        (Platform.isIOS ? capture.height! : arguments.size.height) /
            adjustedSize.destination.height;

    final List<Offset> adjustedOffset = [];
    for (final offset in barcode.corners!) {
      adjustedOffset.add(
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
      );
    }
    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
