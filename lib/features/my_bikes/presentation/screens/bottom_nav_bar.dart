import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/my_bike_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/bike_details_screen.dart';
import 'package:smartbike_flutter/features/settings/presentation/controllers/setting_controller.dart';
import 'package:smartbike_flutter/features/settings/presentation/screens/setting_screen.dart';
import 'package:smartbike_flutter/features/user_management/presentation/screens/users_list_screen.dart';
import 'package:smartbike_flutter/main.dart';
import 'package:smartbike_flutter/widgets/ble_loc_listener.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';

import '../../../../constants/strings.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../smartbike_database/smartbike_db_repo.dart';
import '../../data/method_channel_events/method_channel_events_trigger.dart';
import '../../domain/bike_entity/bike_model/sbm_mapping_model.dart';
import 'my_bike_list_screen.dart';


class BottomNavBar extends ConsumerStatefulWidget {
   final BikeData bikeData;
   final bool isStartService;
   BottomNavBar({required this.bikeData,required this.isStartService});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> with SingleTickerProviderStateMixin,WidgetsBindingObserver  {

  TabController? _controller;
  //final StreamController<ServiceStatus> _locationStreamController = StreamController.broadcast();
  //StreamSubscription<ServiceStatus>? _locStream;
  final _platform = const MethodChannel(SMARTBIKE_PLUGIN);
  bool _backButtonTriggered = false;
  bool _appPaused = false;
  bool _initServiceOp = false;
  List<SbmMapping> _sbmMappingList = [];


  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    checkAppUpdate(context,_platform);
    _requestAppPermissions(true);
    //_bleLocListener();
    WidgetsBinding.instance.addObserver(this);
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if(_appPaused){
          _appPaused = false;
          _requestAppPermissions(false);
        }
        log('app_in_resumed');
        break;
      case AppLifecycleState.inactive:
        log('app_in_inactive');
        break;
      case AppLifecycleState.paused:
        _appPaused = true;
        log('app_in_paused');
        break;
      case AppLifecycleState.detached:
        log('app_in_detached');
        break;
    }
  }

  Future<void> _requestAppPermissions(bool _showDialog) async {

    bool _isLowerAndroidVer = true;

    if(Platform.isAndroid){
      _isLowerAndroidVer = await _platform.invokeMethod('checkAndroidVersion');
    }


    List<Permission> permissionList = [];
    bool _blePermStatus = false;
    bool _locPermStatus = false;

    if(_isLowerAndroidVer){
      _blePermStatus = true;
    }

    if (!_isLowerAndroidVer && Platform.isAndroid ) {

      bool isBleConPerm = await Permission.bluetoothConnect.isGranted;
      bool isBleAdvPerm = await Permission.bluetoothAdvertise.isGranted;
      bool isBleScanPerm = await Permission.bluetoothScan.isGranted;

      if ( !isBleConPerm || !isBleAdvPerm || !isBleScanPerm ) {

        permissionList.add(Permission.bluetoothScan);
        permissionList.add(Permission.bluetoothAdvertise);
        permissionList.add(Permission.bluetoothConnect);

      }
    }else{

      if(Platform.isIOS ){
        bool isBlePerm = await Permission.bluetooth.isGranted;
        if(!isBlePerm){
          permissionList.add(Permission.bluetooth);
        }
      }
    }

    bool isLocPerm = await Permission.locationWhenInUse.isGranted;

    if(!isLocPerm){
      permissionList.add(Permission.locationWhenInUse);
    }


    if(permissionList.isNotEmpty){

      Map<Permission, PermissionStatus> permissionMap = await permissionList.request();

      if(permissionMap[Permission.locationWhenInUse] != null && permissionMap[Permission.locationWhenInUse]!.isGranted == false){
        _locPermStatus = false;
      }else{
        _locPermStatus = true;
      }

      if(Platform.isAndroid &&!_isLowerAndroidVer){
        if(!permissionMap[Permission.bluetoothScan]!.isGranted){
          _blePermStatus = false;
        }else{
          _blePermStatus = true;
        }
      }

      if(Platform.isIOS && permissionMap[Permission.bluetooth] != null && permissionMap[Permission.bluetooth]!.isGranted == false){
          _blePermStatus = false;
      }else if(Platform.isIOS && permissionMap[Permission.bluetooth] != null && permissionMap[Permission.bluetooth]!.isGranted == true){
        _blePermStatus = true;
      }
    }else{
      _blePermStatus = true;
      _locPermStatus = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(mounted){
        ref.read(myBikeNativeController.notifier).updateBlePermission(_blePermStatus);
        ref.read(myBikeNativeController.notifier).updateLocPermission(_locPermStatus);
      }
    });

    log('bleLocPermStatus $_blePermStatus  || $_locPermStatus');

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if(_locPermStatus && serviceEnabled){
      if(mounted)
      ref.read(currentLocationController.notifier).getCurrentLocation();
    }

    if(!_blePermStatus || !_locPermStatus){

      if(_showDialog){
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
      return;
    }
    if(!_initServiceOp){
      _initService();
    }
  }

  void _initService() async {
    _initServiceOp = true;
    log('startingServiceFromFlutter_bike_control');
    if(widget.isStartService){
      ref.read(subscribeMethodChannel);
      await _platform.invokeMethod(Constants.START_SERVICE, await AppUtils.getStartServiceRequestBody());
      AppUtils.sendWhiteListToiOS(ref.read(dbRepoProvider));
      await  Future.delayed(Duration(seconds: 2)).then((value) => _initiateConnectionToSBM());
    }else{
      _initiateConnectionToSBM();
    }
  }

  _initiateConnectionToSBM() async{

    List<dynamic> jsonList = jsonDecode(widget.bikeData.sbmMappings);
    _sbmMappingList = jsonList.map((sbmMapping) => SbmMapping.fromJson(sbmMapping)).toList();

    if(_sbmMappingList.isNotEmpty){

      Map<String,dynamic> requestBody = {
        "barcodeID":  _sbmMappingList[0].name,
        "macID":  _sbmMappingList[0].macAddress,
        "encryptionKeyPrimary": _sbmMappingList[0].encKeyPrimary,
        "encryptionKeySecondary":  _sbmMappingList[0].encKeySecondary
      };
      ref.read(settingController.notifier).updateSettingsDataOfSBM(_sbmMappingList);
      log('bike_to_connect : $requestBody');
      await _platform.invokeMethod(Constants.CONNECT_TO_SBM,requestBody);
    }
  }


  Future<bool> _backButtonAction(BuildContext context) async{

    BikeData bikeData = BikeData.fromJson(json.decode(sharedPreferences!.getString(Constants.SELECTED_BIKE_META)!));
    if(bikeData.sbmMappings != '[]'){
      List<dynamic> jsonList = jsonDecode(bikeData.sbmMappings);
      _sbmMappingList = jsonList.map((sbmMapping) => SbmMapping.fromJson(sbmMapping)).toList();
    }else{
      _sbmMappingList = [];
    }
    ref.read(settingController.notifier).clearSettingsData();
    ref.read(currentLocationController.notifier).cancelPositionStream();
    await AppUtils.removeKey(key : Constants.SELECTED_BIKE_META);

    final sbmState = ref.read(myBikeNativeController.select((value) => value.sbmStatus));
    ref.read(myBikeNativeController.notifier).clearBikeBLEMeta();

    if(_sbmMappingList.length != 0){

      ///If tag is connected we wait for the callback to navigate to list_page.
      if(sbmState == SBM_STATE.CONNECTED){
        _backButtonTriggered = true;
        await _platform.invokeMethod(Constants.DISCONNECT_FROM_SBM,'');
      }else{
        ///If tag is disconnected we initiate disconnect none the less
        ///and navigate after slight delay.
        await _platform.invokeMethod(Constants.DISCONNECT_FROM_SBM,'');
        Future.delayed(Duration(milliseconds: 750),(){
          if(mounted)
          Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) => const MyBikeList()), (Route<dynamic> route) => false);
          ref.read(myBikeNativeController.notifier).setBikeFriendlyName('');
        });
      }
    }else{
      Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) => const MyBikeList()), (Route<dynamic> route) => false);
      ref.read(myBikeNativeController.notifier).setBikeFriendlyName('');
    }

    return true;
  }

  /*======================================location and bluetooth listeners===================================*/
  // Future<void> _bleLocListener() async {
  //
  //   final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if(serviceEnabled == false){
  //     _locationStreamController.add(ServiceStatus.disabled);
  //     WidgetsBinding.instance.addPostFrameCallback((_) async {
  //       ref.read(myBikeNativeController.notifier).notifyLocStatus(false);
  //     });
  //   }
  //   else{
  //     _locationStreamController.add(ServiceStatus.enabled);
  //     WidgetsBinding.instance.addPostFrameCallback((_) async {
  //       ref.read(currentLocationController.notifier).getCurrentLocation();
  //       ref.read(myBikeNativeController.notifier).notifyLocStatus(true);
  //     });
  //   }
  //
  //   _locStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
  //     _locationStreamController.add(status);
  //
  //     if(status == ServiceStatus.enabled){
  //         ref.read(currentLocationController.notifier).getCurrentLocation();
  //         ref.read(myBikeNativeController.notifier).notifyLocStatus(true);
  //     }else{
  //         ref.read(currentLocationController.notifier).cancelPositionStream();
  //         ref.read(myBikeNativeController.notifier).notifyLocStatus(false);
  //     }
  //   });
  //
  //   if(Platform.isIOS){
  //     final _bleStatus = await _flutterBluePlus.isOn;
  //     if(_bleStatus){
  //       WidgetsBinding.instance.addPostFrameCallback((_) async {
  //         ref.read(myBikeNativeController.notifier).notifyBleStatus(true);
  //       });
  //     }else{
  //       WidgetsBinding.instance.addPostFrameCallback((_) async {
  //         ref.read(myBikeNativeController.notifier).notifyBleStatus(false);
  //       });
  //     }
  //
  //     _bleSubscription = _flutterBluePlus.state.listen((state) {
  //
  //       if(state == BluetoothState.on){
  //         ref.read(myBikeNativeController.notifier).notifyBleStatus(true);
  //       }else{
  //         ref.read(myBikeNativeController.notifier).notifyBleStatus(false);
  //       }
  //     });
  //   }else{
  //     AppUtils.updateBleState(ref);
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {

    final sbmStatus = ref.watch(myBikeNativeController.select((value) => value.sbmStatus));
    if(sbmStatus == SBM_STATE.DISCONNECTED && _backButtonTriggered){
      Future.delayed(Duration.zero, () {
        Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) => const MyBikeList()), (Route<dynamic> route) => false);
      });
    }

    return WillPopScope(
      onWillPop:(){
        return _backButtonAction(context);
      },
      child: Scaffold(
        body: Container(
          alignment: Alignment.topLeft,
         height: MediaQuery.of(context).size.height,
         width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 50.h,bottom: 20.h),
          decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(icBg), fit: BoxFit.fill)),
          child: Column(
            children: [
              _titleHeadingBar(),
               Expanded(
                 child: TabBarView(
                   physics: const NeverScrollableScrollPhysics(),
                  controller: _controller,
                  children:  [
                     BikeDetailScreen(bikeData : widget.bikeData),
                    UsersListScreen(),
                    SettingScreen(bikeData : widget.bikeData)
                  ],
              ),
             ),
              _bottomNavigationBarView(),
            ],
          ),
        ),
      ),
    );
  }

  /*=============================================title Heading Bar=======================================*/
  Widget _titleHeadingBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 20.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Consumer(
           builder: (BuildContext context, WidgetRef ref, Widget? child) {
             return InkWell(
               onTap: (){
                 _backButtonAction(context);
               },
               child: Container(
                 height: 25.h,
                width: 40.h,
                 padding: EdgeInsets.symmetric(vertical: 2.h),
                 child: Image.asset(icArrow,),
               ),
             );
           },

         ),
          10.pw,
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              String bikeFriendlyName = ref.watch(myBikeNativeController.select((value) => value.bikeFriendlyName));
              String title = bikeFriendlyName != "" ? bikeFriendlyName  :  widget.bikeData.friendlyName != "" ? widget.bikeData.friendlyName:widget.bikeData.name;
              return  Expanded(
                child: text(
                    title: title,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: headingBlackTextColor),
              );
            },

          ),
          BleLocListener(),
        ],
      ),
    );
  }


/*=============================================bottom Navigation Bar======================================*/
 Widget _bottomNavigationBarView(){
   return Consumer(
     builder: (BuildContext context, WidgetRef ref, Widget? child) {
       return Container(
         margin: EdgeInsets.only(top: 10.h,left: 20.w,right: 20.w,),
         height: 50.h,
         decoration:  BoxDecoration(
             color: bottomBarColor,
             borderRadius: BorderRadius.circular(18.r) ),
         child: TabBar(
           indicatorSize: TabBarIndicatorSize.label,
           indicatorWeight: 6.h,
           indicatorColor: indicatorColor,
           padding: EdgeInsets.symmetric(horizontal: 30.w,),
           controller: _controller,
           onTap: (int value){
           },
           tabs:  [
             Tab(icon: Image.asset(icHome,height: 25.h,color: Colors.grey.shade800,)),
             Tab(icon: Image.asset(icUser,height: 25.h,color: Colors.grey.shade800)),
             Tab(icon: Image.asset(icSetting,height: 25.h,color: Colors.grey.shade800)),
           ],
         ),
       );
     },
   );
 }


  @override
  dispose() {
    super.dispose();
  //  _locationStreamController.close();
    // if(_locStream != null){
    //   _locStream!.cancel();
    // }
    WidgetsBinding.instance.addObserver(this);
  }
}
