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
    center: MediaQuery.of(context).size.center(Offset.zero),
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
              height: 140.h,
              padding: EdgeInsets.only(top: 50.h,left: 20.w,right: 20.w),
              color: Colors.black.withOpacity(0.6),
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
                          padding: EdgeInsets.only(top: 3.h),
                          child: Image.asset(icBackArrow,scale: 2.0.h,))),
                  20.pw,
                  Expanded(child: text(title: LocaleKeys.keyScanVehicle.tr(),textAlign: TextAlign.start,
                      color: whiteColor,fontSize: 20.sp,fontWeight: FontWeight.w500)),
                  20.pw,
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: (){
                      ref.watch(bikeAdminController.notifier).setErrorBox(false);
                      ref.watch(bikeAdminController.notifier).setBarcodeData(null);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 3.h),
                      child: Image.asset(icRefresh,scale: 2.5.h,),
                    ),
                  )
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 230.h,
              color: Colors.black.withOpacity(0.6),
              child: _scannedDetailView(),
            ),
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
        return Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.h,vertical: 15.h),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Visibility(
                  visible: barcode?.displayValue != null ,
                  child: text(title: LocaleKeys.keyInfo.tr(),color: whiteColor,fontSize: 20.sp,fontWeight: FontWeight.w700)),
              Visibility(
                  visible: barcode?.displayValue != null ,
                  child: Divider(color: whiteColor,)),
              Visibility(
                  visible: barcode?.displayValue != null ,
                  child: text(title: "${LocaleKeys.keyId.tr()} : ${barcode?.displayValue}",color: whiteColor,fontSize: 14.sp,fontWeight: FontWeight.w500)),
              10.ph,
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final visibility =  ref.watch(bikeAdminController.select((value) => value.isErrorBox));
                  return Visibility(
                    visible: visibility,
                    child: Padding(
                      padding:  EdgeInsets.only(top: 2.0.h,bottom: 8.h),
                      child: errorWidget(subTitle: LocaleKeys.keyScannedId.tr(), ),
                    ),
                  );
                },
              ),
              _submitButton(),
            ],),
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
      return Visibility(
        visible: barcode?.displayValue != null,
        child: commonButton(
          onTap: () async {
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
          buttonColor: [const Color.fromRGBO(47, 64, 126, 1.0), const Color.fromRGBO(109, 69, 194, 1.0)],
          buttonText: LocaleKeys.keySubmit.tr(),
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