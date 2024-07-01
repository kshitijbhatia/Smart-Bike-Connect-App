import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/sbm_mapping_model.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/bike_admin_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/my_bike_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/scanner_screen.dart';
import 'package:smartbike_flutter/features/settings/presentation/controllers/setting_controller.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/main.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/custom_loader_dialogs.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

import '../../../../app_utils/app_utils.dart';
import '../../../service/user_perm_controller.dart';


class SettingScreen extends ConsumerStatefulWidget {
  final BikeData? bikeData;
  SettingScreen({this.bikeData});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  TextEditingController _sbmNumberTextController = TextEditingController();
  TextEditingController _bikeNameTextController = TextEditingController();
  GlobalKey _toolTipKey = GlobalKey();
  final _platform = const MethodChannel(SMARTBIKE_PLUGIN);
  List<SbmMapping> sbmMappingList = [];
  bool _smartnessTriggered = false;
  int? primaryUserId;
  late SharedPreferences sharedPreferences;
  String vinName = '';

  @override
  void initState() {
    super.initState();
    _fetchPrimaryUserId();
    _initialisation();
  }

  void _initialisation() {
    if (widget.bikeData!.sbmMappings != '[]') {
      List<dynamic> jsonList = jsonDecode(widget.bikeData!.sbmMappings);
      sbmMappingList = jsonList.map((sbmMapping) => SbmMapping.fromJson(sbmMapping)).toList();
      log("sbmMappingList ${jsonEncode(sbmMappingList)}");
    }
  }
/*=================================================fetch Login User Id===============================================*/

  void _fetchPrimaryUserId(){
    Map userMapping = jsonDecode(widget.bikeData!.userMappings);
    Map primaryElement = userMapping['primary'];
    primaryUserId = primaryElement['user_id'];
    log("loginId and primaryUserId ${Constants.GLOBAL_USER_ID} $primaryUserId");
    if(widget.bikeData != null){
      if(widget.bikeData!.name.length > 16){
        vinName = widget.bikeData!.name.substring(0,8) + '...'+ widget.bikeData!.name.substring(widget.bikeData!.name.length - 7,widget.bikeData!.name.length);
      }else{
        vinName = widget.bikeData!.name;
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          34.ph,
          _bikeNameTextView(),
          20.ph,
          listTileView(
            title: LocaleKeys.keyVin.tr(),
            subTitleWidget: /*Tooltip(
              showDuration: const Duration(seconds: 2),
              triggerMode: TooltipTriggerMode.longPress,preferBelow: false,
              decoration: BoxDecoration(color: greyBoldColor ,borderRadius: BorderRadius.circular(5.r)),
              textStyle:  TextStyle(color: whiteColor,fontSize: 14.sp),
              message: '${widget.bikeData!.name}',
              child: text(
                  title: vinName,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: blackColor),
            )*/GestureDetector(
              onTap: () {
                final dynamic _toolTip = _toolTipKey.currentState;
                _toolTip.ensureTooltipVisible();
              },
              onLongPress: (){
                final dynamic _toolTip = _toolTipKey.currentState;
                _toolTip.ensureTooltipVisible();
              },
              child: Tooltip(
                showDuration: const Duration(seconds: 2),
                key: _toolTipKey,
                preferBelow: false,
                decoration: BoxDecoration(color: greyBoldColor ,borderRadius: BorderRadius.circular(5.r)),
                textStyle:  TextStyle(color: whiteColor,fontSize: 14.sp),
                message: '${widget.bikeData!.name}',
                child: text(
                    title: vinName,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: blackColor),

              ),
            ),
            leadingIcons: icVin,
            padding: 25.pw,
            leadingHeight: 2.0.h,
            onTap: (){},
            trailingIcon: Container(),
          ),
          20.ph,
          listTileView(
            title: LocaleKeys.keyBikeModel.tr(),
            subTitle: widget.bikeData?.modelName ?? '',
            leadingIcons: icBikeModel,
            padding: 25.pw,
            leadingPadding : 10.pw,
            onTap: (){},
            trailingIcon:  Container(),
          ),
          20.ph,
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child){
              final _learnModeVisibility = ref.watch(userPermController.select((value) => value.isLearnModeAllowed));
              final _isCurdSBMAllowed = ref.watch(userPermController.select((value) => value.isCURDSBMAllowed));

              return listTileView(
                  title: LocaleKeys.keySBMModule.tr(),
                  subTitle: _learnModeVisibility ? LocaleKeys.keyEdit.tr() : LocaleKeys.keyView.tr(),
                  leadingIcons: icSBMModule,
                  onTap: () {

                    _sbmNumberTextController.clear();
                    if(sbmMappingList.length != 0){
                      _bottomSheetView(child: _sbmModuleView());
                    }else{
                      _bottomSheetView(
                          height:  MediaQuery.of(context).size.height/1.4.h,
                          child: _isCurdSBMAllowed ? _addNewSBMView() : _noSbmAttachedView());
                    }
                  });
            },
          ),
          10.ph,
          _smartnessView(),
        ],
      ),
    );
  }

  Widget _bikeNameTextView(){
    return
      Padding(
        padding: EdgeInsets.symmetric(horizontal:  20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:  EdgeInsets.only(top: 5.h),
              child: Image.asset(icBikeName,scale: 2.5.h),
            ),
            10.pw,
            Expanded(
              flex: 1,
              child: text(title:  LocaleKeys.keyBikeName.tr(), maxLines: 1,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: blackColor),
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                String bikeFriendlyName = ref.watch(myBikeNativeController.select((value) => value.bikeFriendlyName));
                String title = bikeFriendlyName != "" ? bikeFriendlyName  :  widget.bikeData!.friendlyName != "" ? widget.bikeData!.friendlyName:'NA';
                return Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: text(
                            title : title.length > 10 ? '${title.substring(0,title.length-4)}...' : title, fontSize: 16.sp,
                            fontWeight: FontWeight.w500,maxLines: 1,textOverflow: TextOverflow.ellipsis,
                            color: title.trim() == "NA" ? Colors.grey : blackColor),
                      ),
                      5.pw,
                      InkWell(
                          onTap: (){
                            if(title.trim() == 'NA'){
                              _bikeNameTextController.text = '';
                            }else{
                              _bikeNameTextController.text = title;
                            }
                            ref.watch(bikeAdminController.notifier).setButtonColor(true);
                            _bottomSheetView(
                                title: LocaleKeys.keyEditBike.tr(),
                                child: _bikeNameBottomView(),height:  MediaQuery.of(context).size.height/1.4.h);
                          },
                          child: Image.asset(icEdit,scale: 2.8.h,))
                    ],
                  ),
                );
              },
            ),
          ],),
      );
  }

  /*======================================================_bike Name Bottom View===============================*/

  Widget _bikeNameBottomView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          15.ph,
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final bikeAdmin = ref.watch(bikeAdminController.notifier);
              return textFormField(
                  keyboardType: TextInputType.text,
                  controller: _bikeNameTextController,
                  suffixOnTab: (){
                    _bikeNameTextController.clear();
                    bikeAdmin.setButtonColor(false);
                  },
                  contentPadding: EdgeInsets.all(10.h),
                  textInputAction: TextInputAction.done, inputFormatters: [],
                  hintText: LocaleKeys.keyEnterBike.tr(),
                  onChanged: (value){
                    if(value.toString().isNotEmpty){
                      bikeAdmin.setButtonColor(true);
                    }else{
                      bikeAdmin.setButtonColor(false);
                    }
                  },
                  maxLength: 20);
            },
          ),
          15.ph,
          Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final buttonColor = ref.watch(bikeAdminController.select((value) => value.buttonColor));
            final settingProvider = ref.watch(settingController.notifier);
            return commonButton(
              onTap: buttonColor == false ? (){}:() async {
                CustomLoaderDialog.buildShowDialog(context);
                bool? result =  await settingProvider.editBikeName(vehicleId: widget.bikeData!.id, userId: Constants.GLOBAL_USER_ID, updatedBikeName: _bikeNameTextController.text.trim());
                if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                if(result == true){
                  ref.watch(bikeAdminController.notifier).setButtonColor(false);
                  Navigator.pop(context);
                  ref.watch(myBikeNativeController.notifier).setBikeFriendlyName(_bikeNameTextController.text.trim());
                }

              },
              buttonColor: buttonColor == true ? [const Color.fromRGBO(47, 64, 126, 1.0), const Color.fromRGBO(109, 69, 194, 1.0)] :[Colors.grey, Colors.grey],
              buttonText: LocaleKeys.keySubmit.tr(),
            );
          },
          ),
          15.ph,
        ],
      ),
    );
  }

/*===============================================smartnessView===============================*/

  Widget _smartnessView(){

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {

        final smartnessValue = ref.watch(settingController.select((value) => value.smartnessValue));
        final smartnessColor = ref.watch(settingController.select((value) => value.smartnessColor));
        final sbmState = ref.watch(myBikeNativeController.select((value) => value.sbmStatus));
        final _isSmartnessAllowed = ref.watch(userPermController.select((value) => value.isSmartnessControl));
        final settingProvider = ref.watch(settingController.notifier);
        ref.listen<String>(myBikeNativeController.select((value) => value.smartnessChanged), (previous, result) async{
          _smartnessTriggered = false;
          log('insideSmartnessListen $result');
          ref.read(settingController.notifier).setSmartnessColor(false);
          if(result != Constants.SMARTNESS_FAILED){
            if (result == Constants.SMARTNESS_ENABLE_TEXT) {
              ref.read(settingController.notifier).setSmartnessValue(0);
              //showToast(LocaleKeys.toastSmartnessDisable.tr(),warning: false);
              _updateSmartnessOnCloud(context,settingProvider,false);
            } else {
              ref.read(settingController.notifier).setSmartnessValue(1);
              //showToast(LocaleKeys.toastSmartnessEnable.tr(),warning: false);
              _updateSmartnessOnCloud(context,settingProvider,true);
            }
          }else{
            Future.delayed(Duration(milliseconds: 500),(){
              if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
            });
            showToast(LocaleKeys.toastFailedToChangeSmartness.tr(),warning: true,duration: true);
          }
        });

        bool _isSmartnessNotAllowed = true;

        if((_isSmartnessAllowed || Constants.GLOBAL_USER_ID == primaryUserId) && sbmState == SBM_STATE.CONNECTED && !smartnessColor){
          _isSmartnessNotAllowed = false;
        }else if( (!_isSmartnessAllowed && Constants.GLOBAL_USER_ID != primaryUserId) || sbmState == SBM_STATE.DISCONNECTED  || smartnessColor){
          _isSmartnessNotAllowed = true;
        }

        log('smartnessAllowed $_isSmartnessNotAllowed');
        return listTileView(
          title: LocaleKeys.keySmartness.tr(),
          subTitle: '',
          leadingIcons: icSmartness,
          onTap: (){},
          subTitleColor: _isSmartnessNotAllowed  ? Colors.grey: blackColor,
          trailingIcon: _SmartnessSwitch(smartnessValue == 1 ? true:  false,_isSmartnessNotAllowed,_isSmartnessAllowed,sbmState),
          subTitleWidget: Container(),

          // InkWell(
          //     splashColor: Colors.transparent,
          //     highlightColor: Colors.transparent,
          //     onTap: !_isSmartnessAllowed || sbmState == SBM_STATE.DISCONNECTED ? (){} : () async {
          //
          //       String SMARTNESS;
          //       if(!_smartnessTriggered){
          //         if(smartnessValue == 0){
          //           SMARTNESS = 'ENABLE';
          //         }else{
          //           SMARTNESS = 'DISABLE';
          //         }
          //         log('smartnessAsParam $SMARTNESS');
          //         bool status = await _platform.invokeMethod(Constants.CHANGE_SMARTNESS,SMARTNESS);
          //         if(!status){
          //           showToast(LocaleKeys.toastFailedToChangeSmartness.tr(),warning: true,duration: true);
          //           return;
          //         }
          //         _smartnessTriggered = true;
          //         ref.read(settingController.notifier).setSmartnessColor(true);
          //       }else{
          //         showToast(LocaleKeys.toastPleaseWait.tr());
          //       }
          //     },
          //     child: smartnessValue == 1 ? Icon(
          //         Icons.radio_button_on,
          //         size: 20.h,
          //         color : _isSmartnessNotAllowed  ? Colors.grey: blackColor)
          //         : Icon(
          //       Icons.radio_button_off,
          //       color: _isSmartnessNotAllowed  ? Colors.grey: blackColor,
          //       size: 20.h,
          //     )),
        );
      },
    );
  }

  _SmartnessSwitch(bool _smartnessValue,bool _isSmartnessNotAllowed,bool _isSmartnessOperationAllowed,SBM_STATE sbm_state){
    return Transform.scale(
      scale: 1.2,
      child: Opacity(
        opacity: _isSmartnessNotAllowed  ? .5 : 1,
        child: Switch(
          activeColor: blackColor,
          value: _smartnessValue,
          onChanged: (newSmartnessValue) async{
            if(!_isSmartnessOperationAllowed || sbm_state == SBM_STATE.DISCONNECTED){
              showToast(LocaleKeys.toastOperationNotAllowed.tr(), warning: true);
            }else{

              String SMARTNESS;
              if(!_smartnessTriggered){
                if(newSmartnessValue){
                  SMARTNESS = Constants.SMARTNESS_ENABLE_TEXT;
                }else{
                  SMARTNESS = Constants.SMARTNESS_DISABLE_TEXT;
                }

                log('smartnessAsParam $SMARTNESS');
                Map<String,dynamic> smartnessRequestBody = {
                  'SmartnessValue' : SMARTNESS,
                  'isSmartnessCallbackRequired' : true
                };

                bool status = await _platform.invokeMethod(Constants.CHANGE_SMARTNESS,smartnessRequestBody);
                if(!status){
                  showToast(LocaleKeys.toastFailedToChangeSmartness.tr(),warning: true,duration: true);
                  return;
                }
                CustomLoaderDialog.buildShowDialog(context);
                _smartnessTriggered = true;
                ref.read(settingController.notifier).setSmartnessColor(true);
              }else{
                showToast(LocaleKeys.toastPleaseWait.tr());
              }
            }
          },
        ),
      ),
    );
  }



/*===========================================================sbm Module View===============================*/
  Widget _sbmModuleView() {
    return Consumer(
      builder: (BuildContext bottomSheetContext, WidgetRef _ref, Widget? child) {

        final sbmStatus = _ref.watch(myBikeNativeController.select((value) => value.sbmStatus));
        final showLoader = _ref.watch(settingController.select((value) => value.isSendLearnModeLoader));
        final settingsController = _ref.watch(settingController.notifier);
        final _learnModeVisibility = _ref.watch(userPermController.select((value) => value.isLearnModeAllowed));
        final _isCurdSBMAllowed = _ref.watch(userPermController.select((value) => value.isCURDSBMAllowed));
        final dfuButtonVisibility = _ref.watch(settingController.select((value) => value.dfuButtonVisibility));
        final dfuProgressPercentage =  _ref.watch(settingController.select((value) => value.dfuProgressPercentage));

        _ref.listen<bool>(settingController.select((value) => value.isSendLearnModeLoader), (previous, result) {
          if(!result){
            Navigator.pop(bottomSheetContext);
          }
        });

        bool _isLearnModeNotAllowed = true;

        if(_learnModeVisibility && sbmStatus == SBM_STATE.CONNECTED && !showLoader){
          _isLearnModeNotAllowed = false;
        }else if(!_learnModeVisibility || sbmStatus == SBM_STATE.DISCONNECTED || showLoader){
          _isLearnModeNotAllowed = true;
        }

        bool _dfuVisibility = false;

        if(dfuButtonVisibility && !_isLearnModeNotAllowed){
          _dfuVisibility = true;
        }

        _ref.listen<int?>(settingController.select((value) => value.dfuProgressPercentage), (previous, result) {
          ///Result 101 means either dfu is completed or canceled
          if(result != null && result == 101){

            _onDfuDialogDismiss(bottomSheetContext);

          }else if(result != null && result == -1){
            CustomLoaderDialog.buildShowDialog(context, title: LocaleKeys.keyDfuDialog.tr());
          }
        });

        final firmwareVersion = _ref.watch(settingController.select((value) => value.firmwareVersion));

        return Column(
          children: [
            15.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: text(
                      title: '${sbmMappingList[0].name}',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: blackColor),
                ),
                Visibility(
                  visible: _isCurdSBMAllowed,
                  child: InkWell(
                    onTap: (){
                      appCommonDialog(
                          context: bottomSheetContext,
                          title: LocaleKeys.keyDelete.tr(),
                          descriptionText: LocaleKeys.keyDeleteSBMDes.tr(),
                          onTap: () async {

                            Navigator.pop(bottomSheetContext); ///Dismissing the confirmation dialog box

                            CustomLoaderDialog.buildShowDialog(bottomSheetContext); ///Displaying API loader

                            bool? result = await settingsController.deleteSBMVehicleMapping(vehicleId: widget.bikeData!.id ,sbmId: sbmMappingList[0].id!);

                            if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext); ///Dismissing API loader

                            if(result == true){

                              ///DROPPING CONNECTION FROM SBM
                              ref.read(myBikeNativeController.notifier).bikeButtonStatus('');
                              ref.read(myBikeNativeController.notifier).lastParkedLocationState('');
                              ref.read(myBikeNativeController.notifier).bikeVicinityStatusState('NOT_SEEN');
                              ref.watch(settingController.notifier).setFirmwareVersion('');

                              await _platform.invokeMethod(Constants.DISCONNECT_FROM_SBM,"");
                              Navigator.pop(bottomSheetContext); /// Dismissing SBM_Module bottomSheet
                              _bottomSheetView(child: _addNewSBMView(),height:  MediaQuery.of(bottomSheetContext).size.height/1.4.h);
                              Future.delayed(Duration(milliseconds: 500),() async{
                                sbmMappingList.clear();
                              });
                            }
                          });
                    },
                    child: Image.asset(
                      icDelete,
                      scale: 2.5.h,
                    ),
                  ),
                ),
              ],
            ),
            15.ph,
            _textWidget(title: LocaleKeys.keyHardwareVersion.tr(), subTitle: '${sbmMappingList[0].hwVer}'),
            10.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                text(
                    title: LocaleKeys.keyFirmwareVersion.tr(),
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: greyBoldColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Visibility(
                        visible: _dfuVisibility,
                        child: _DFUButton(bottomSheetContext,dfuProgressPercentage)),
                    10.pw,
                    text(
                        title: firmwareVersion != '' ? firmwareVersion : '${sbmMappingList[0].swVer}',
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        color: greyBoldColor),
                  ],
                ),
              ],
            ),
            10.ph,
            _textWidget(
                title: LocaleKeys.keyMacAddress.tr(),
                subTitle: '${sbmMappingList[0].macAddress}'),
            _learnModeVisibility ? 25.ph : 0.ph,
            _learnModeVisibility ? commonButton(
                onTap: _isLearnModeNotAllowed ?  (){
                  if(_learnModeVisibility && sbmStatus == SBM_STATE.DISCONNECTED && !showLoader){
                    showToast(LocaleKeys.toastFailedToSendLearnCommand.tr(),warning: true);
                  }
                } : () async {
                  int status = await _platform.invokeMethod(Constants.SEND_LEARN_MODE,"");
                  if(status == 301){
                    showToast(LocaleKeys.toastUnlockBike.tr(),warning: true,duration: true);
                    return;
                  }else if(status == 302){
                    showToast(LocaleKeys.toastTurnOnIgnition.tr(),warning: true,duration: true);
                    return;
                  }
                  _ref.watch(settingController.notifier).setSendLearnModeLoader(true);
                },
                isLoader: showLoader,
                buttonText:  LocaleKeys.keySendLearn.tr(),
                buttonColor: !_learnModeVisibility || sbmStatus == SBM_STATE.DISCONNECTED ? [Colors.grey , Colors.grey]: [
                  const Color.fromRGBO(47, 64, 126, 1.0),
                  const Color.fromRGBO(109, 69, 194, 1.0)
                ],
                fontSize: 14.sp,
                fontWeight: FontWeight.w800
            ) : Container(),
            _learnModeVisibility ? 10.ph : 0.ph,
          ],
        );
      },
    );
  }

  /*=======================================================scan QR View===============================*/
  Widget _addNewSBMView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        children: [
          15.ph,
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final bikeAdmin = ref.watch(bikeAdminController.notifier);
              return textFormField(
                  keyboardType: TextInputType.text,
                  controller: _sbmNumberTextController,
                  contentPadding: EdgeInsets.all(10.h),
                  suffixOnTab: (){
                    _sbmNumberTextController.clear();
                    bikeAdmin.setButtonColor(false);
                  },
                  textInputAction: TextInputAction.done,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                  ],
                  hintText: LocaleKeys.keyEnterModuleId.tr(),
                  onChanged: (value){
                    if(value.toString().isNotEmpty){
                      bikeAdmin.setButtonColor(true);
                    }else{
                      bikeAdmin.setButtonColor(false);
                    }
                  },
                  maxLength: 50);
            },
          ),
          15.ph,
          Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final settingsController = ref.watch(settingController.notifier);
            final buttonColor = ref.watch(bikeAdminController.select((value) => value.buttonColor));
            final bikeAdmin = ref.watch(bikeAdminController.notifier);
            return commonButton(
              onTap: () async {
                if(_sbmNumberTextController.text.trim().length > 0){
                  CustomLoaderDialog.buildShowDialog(context);
                  sbmMappingList = await settingsController.getSBMId( barCode:  _sbmNumberTextController.text.trim() , vehicleId: widget.bikeData!.id);
                  log('sbmMappingList ${jsonEncode(sbmMappingList)}');
                  if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
                  if(sbmMappingList.isNotEmpty){
                    Navigator.pop(context);
                    Map<String,dynamic> requestBody = {
                      "barcodeID":  sbmMappingList[0].name,
                      "macID":  sbmMappingList[0].macAddress,
                      "encryptionKeyPrimary": sbmMappingList[0].encKeyPrimary,
                      "encryptionKeySecondary":  sbmMappingList[0].encKeySecondary
                    };
                    log('bike_to_connect : $requestBody');
                    await _platform.invokeMethod(Constants.CONNECT_TO_SBM,requestBody);
                    _sbmNumberTextController.clear();
                    bikeAdmin.setButtonColor(false);
                    _bottomSheetView(child: _sbmModuleView());
                  }
                }
              },
              buttonColor: buttonColor == true ? [const Color.fromRGBO(47, 64, 126, 1.0), const Color.fromRGBO(109, 69, 194, 1.0)] :[Colors.grey, Colors.grey],
              buttonText: LocaleKeys.keySubmit.tr(),
            );
          },
          ),
          15.ph,
          _dividerView(),
          15.ph,
          commonButton(
              buttonText: LocaleKeys.keyScanQR.tr(),
              textColor: buttonTextColor,
              onTap: () async {
                if(await _requestCameraPermissionThenNavigate()){
                  var data = await Navigator.push(this.context, MaterialPageRoute(builder: (context) =>  ScannerScreen()));
                  if(data != null){
                    _sbmNumberTextController.text = data;
                  }
                }
              },
              buttonColor: [
                whiteColor,
                whiteColor,
              ]),
          15.ph,
        ],
      ),
    );
  }

  /*=======================================================No SBM Attach View===============================*/
  Widget _noSbmAttachedView(){
    return text(title: LocaleKeys.keyInstallSbm.tr(),
        color: blackColor, textAlign: TextAlign.left,
        maxLines: 4,fontSize: 14.sp,fontWeight: FontWeight.w500);
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

/*==========================================================text Widget===============================*/

  Widget _textWidget({String? title, String? subTitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: text(
              title: title,
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
              color: greyBoldColor),
        ),
        text(
            title: subTitle,
            fontWeight: FontWeight.w400,
            fontSize: 13.sp,
            color: greyBoldColor),
      ],
    );
  }


  Widget _DFUButton(BuildContext context,int? dfuProgressPercentage){

    return commonButton(
        onTap: () async{

          String fileName = sbmMappingList[0].functionality!.dfuConfig!.targetFileName;
          Tuple<String, bool> filePath = await AppUtils.getFilePath(fileName: fileName);

          log('zipFileName $fileName || ${sbmMappingList[0].functionality!.dfuConfig!.targetFirmware}');
          log('filePathCheck ${filePath.item1}');

          if(!filePath.item2){
            CustomLoaderDialog.buildShowDialog(context,title: LocaleKeys.keyDownloadZipDialog.tr());
            bool response = await ref.read(settingController.notifier).downloadZIP(fileName: fileName, filePath: filePath.item1);
            if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
            if(!response) return;
          }

          try{

            if(Platform.isAndroid){

            await _platform.invokeMethod(Constants.INITIATE_DFU,filePath.item1);

          }else if(Platform.isIOS){

                log('initiating_dfu_iOS ${DateTime.now()}');

                String deviceUUID = await _platform.invokeMethod(Constants.DEVICE_UUID,'');

                if(deviceUUID != 'UUID_NOT_AVAILABLE'){

                  CustomLoaderDialog.buildShowDialog(context, title: LocaleKeys.keyDfuDialog.tr());

                  await NordicDfu().startDfu(
                    deviceUUID,
                    filePath.item1,
                    name: 'TVS SBM',
                    fileInAsset: false,
                    onProgressChanged: (deviceAddress, percent, speed, avgSpeed, currentPart, partsTotal) {
                      log('deviceAddress: $deviceAddress, percent: $percent');
                    },
                    onDfuCompleted:(address){
                      log('onDfuCompletedIoS : $address');
                      _onDfuDialogDismiss(context);
                      showToast(LocaleKeys.toastDFUSuccessful.tr(),warning: false,duration: true);
                    },
                    onDfuAborted:(address){
                      log('onDfuAbortedIoS : $address');
                      _onDfuDialogDismiss(context);
                      showToast(LocaleKeys.toastDfuCancelled.tr(),warning: true,duration: true);
                    },
                    onError: (address, error, errorType, message){
                      log('onErrorIoS : $address | $error $errorType | $message');
                      _onDfuDialogDismiss(context);
                      showToast(LocaleKeys.toastDfuError.tr(),warning: true,duration: true);
                    },
                    onDeviceConnected: (address){
                      log('onDeviceConnectedIoS ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}');
                    },
                    onDeviceConnecting: (address){
                      //gets called just after starting the DFU process (1 in order)
                      log('onDeviceConnectingIoS ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}');
                    },
                    onDeviceDisconnected: (address){
                      log('onDeviceDisconnectedIoS ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}');
                    },
                    onDeviceDisconnecting: (address){
                      //usually gets called at the end when dfu is completed
                      log('onDeviceDisconnectingIoS ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}');
                    },
                    onDfuProcessStarted: (address){
                      log('onDfuProcessStartedIoS ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}');
                    },
                    onDfuProcessStarting: (address){
                      //after DFU services are discovered this callback is called (2nd in order)
                      log('onDfuProcessStartingIoS ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}');
                    },
                    onFirmwareValidating: (address){
                      log('onFirmwareValidatingIoS ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}');
                    },
                  );
                }else{
                  showToast(LocaleKeys.toastDfuIoSUUIDError.tr(),warning: true,duration: true);
                }
              }
          }catch(exc,stacktrace){
            log('dfu_Exc ${exc.toString()}',stackTrace: stacktrace);
            showToast(LocaleKeys.toastDfuError.tr(),warning: true,duration: true);
            _onDfuDialogDismiss(context);
          }
        },
        height: 20.h,
        width: LocaleKeys.keyDfu.tr().length > 6 ? 75.w : 60.w,
        buttonText: LocaleKeys.keyDfu.tr(),
        buttonColor:  [
          const Color.fromRGBO(47, 64, 126, 1.0),
          const Color.fromRGBO(109, 69, 194, 1.0)
        ],
        fontSize: 10.sp,
        fontWeight: FontWeight.w600
    );
  }

  /*=======================================bottom Sheet View================================================*/

  void _bottomSheetView({Widget? child, String? title,double? height}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.r),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromRGBO(255, 255, 255, 1.0),
                    const Color.fromRGBO(227, 248, 255, 1.0),
                  ]),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          icArrow,
                          color: Color.fromRGBO(47, 64, 126, 1.0),
                          scale: 1.8.h,
                        ),
                      ),
                      10.pw,
                      text(
                          title: title ?? LocaleKeys.keySBMModule.tr(),
                          fontWeight: FontWeight.w800,
                          fontSize: 20.sp,
                          color: Color.fromRGBO(47, 64, 126, 1.0))
                    ],
                  ),
                  10.ph,
                  child ?? Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onDfuDialogDismiss(final BuildContext context){
    log('dfuEndTime ${DateTime.now().millisecondsSinceEpoch}');
   Future.delayed(Duration(milliseconds: 750),(){
     if(CustomLoaderDialog.dialogContext != null){
       if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
     }
     Navigator.pop(context);
     ref.read(settingController.notifier).dfuProgressLoader(null);
   });
  }

  void _updateSmartnessOnCloud(BuildContext context,SettingController settingProvider, bool immobilisation) async{

    bool result =  await settingProvider.uploadSmartness(sbmId: sbmMappingList[0].id!, immobilisation: immobilisation);
    if(result){
      if(immobilisation){
        showToast(LocaleKeys.toastSmartnessEnable.tr(),warning: false);
      }else{
        showToast(LocaleKeys.toastSmartnessDisable.tr(),warning: false);
      }
    }
    Future.delayed(Duration(milliseconds: 500),(){
      if (mounted) Navigator.pop(CustomLoaderDialog.dialogContext);
    });
  }

  Future<bool> _requestCameraPermissionThenNavigate() async {

    bool _isCameraPerm = await Permission.camera.isGranted;

    if ( !_isCameraPerm) {
      await Permission.camera.request();
      if (await Permission.camera.isGranted) {
        return true;
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
      return true;
    }
    return false;
  }
}












