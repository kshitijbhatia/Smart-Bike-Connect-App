
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/bike_admin_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/my_bike_controller.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/bike_admin_screen.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/bottom_nav_bar.dart';
import 'package:smartbike_flutter/features/settings/presentation/screens/account_setting_screen.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/main.dart';
import 'package:smartbike_flutter/widgets/circular_progress_indicatior.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';

import '../../../../smartbike_database/smartbike_db_repo.dart';
import '../../../../widgets/ble_loc_listener.dart';
import '../../../service/user_perm_controller.dart';
import '../../data/method_channel_events/method_channel_events_trigger.dart';
import '../../data/my_bike_repo/my_bike_repo.dart';

class MyBikeList extends ConsumerStatefulWidget {
  const MyBikeList({Key? key}) : super(key: key);

  @override
  ConsumerState<MyBikeList> createState() => _MyBikeListState();
}

class _MyBikeListState extends ConsumerState<MyBikeList> with WidgetsBindingObserver {

  bool _isLowerAndroid = false;
  final _platform = const MethodChannel(SMARTBIKE_PLUGIN);
  bool _appPaused = false;
  bool _initiatedService = false;
  ScrollController _scrollController = ScrollController();
  int limit = 10 , start = 0;
  String _appVersion = '1.0';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchDefaultView();
    _initiateOperations();
    _fetchUserName();
    _paginateTask();
    WidgetsBinding.instance.addObserver(this);
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        log('app_in_resumed');
        if(_appPaused){
          _appPaused = false;
          _requestAppPermissions(false);
        }
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

  /* ======================================================pagination =================================================*/

  _paginateTask() {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if(ref.read(myBikeRepoProvider).dataCount != 0){
          start += 10;
          limit += 10;
          Future.delayed(Duration(milliseconds: 200)).then((value) =>
              ref.read(myBikeAPIController.notifier).getAllBikes(start: (start + 1), limit: limit));
        }
      }
    });
  }

  /*======================================fetch User Name==================================*/

  Future<void> _fetchUserName() async {
    if(await AppUtils.containsKey( key :Constants.USER_NAME)){
      String? name =   await AppUtils.getString(key:Constants.USER_NAME);
      ref.read(myBikeNativeController.notifier).setUserName(name!.substring(0,1).toUpperCase());
    }
  }

  /*======================================fetch Default View from sharedPref==================================*/

  Future<void> _fetchDefaultView() async {

    if( await AppUtils.getString(key: Constants.ROLE) == Constants.BIKE_ADMIN_VIEW){
      ref.read(myBikeNativeController.notifier).setHomePageView(true);
    }
    else{
       ref.read(myBikeNativeController.notifier).setHomePageView(false);
    }
  }

  /*==========================================_initiate Operations=======================================*/

  Future<void> _initiateOperations() async{

    ref.read(subscribeMethodChannel);
    log('AndroidVersion $_isLowerAndroid');
    checkAppUpdate(context,_platform);
    _requestAppPermissions(true);
    _appVersion = await _platform.invokeMethod(Constants.APP_VERSION,'');
    log('appVersionNative $_appVersion');
  }

  /*===========================================_request Permissions=======================================*/
  Future<void> _requestAppPermissions(bool showDialog) async {

    if (Platform.isAndroid) {
      _isLowerAndroid = await _platform.invokeMethod('checkAndroidVersion');
    }

    List<Permission> permissionList = [];
    bool _openSettings = false;

    if (!_isLowerAndroid && Platform.isAndroid ) {

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
        _openSettings = true;
      }

      if(Platform.isAndroid && !_isLowerAndroid){
        if(!permissionMap[Permission.bluetoothScan]!.isGranted){
          _openSettings = true;
        }
      }

      if(Platform.isIOS && permissionMap[Permission.bluetooth] != null && permissionMap[Permission.bluetooth]!.isGranted == false){
        _openSettings = true;
      }

    }

     if(_openSettings){
       if(showDialog){
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


     if(!_initiatedService){
       _initiatedService = true;
       log('startingServiceFromFlutter');
       await _platform.invokeMethod(Constants.START_SERVICE, await AppUtils.getStartServiceRequestBody());
       if(mounted)
         WidgetsBinding.instance.addPostFrameCallback((_) async {
           if(mounted){
             Future.delayed(Duration(seconds: 2)).then((value) => AppUtils.sendWhiteListToiOS(ref.read(dbRepoProvider)));
           }
         });
     }
  }

  @override
  Widget build(BuildContext context) {
    log('saved_locale_is ${context.locale}');

    return Scaffold(
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          padding: EdgeInsets.only(top: 50.h, bottom: 20.h, left: 20.w, right: 20.w),
          decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(icBg), fit: BoxFit.fill)
          ),
          child: Column(
            children: [
              _titleHeadingBar(),
              //TODO
              ///1. Why there is delay in fetching role value
              ///2. Why after implementing role as null, bike_list_api getting called issue is getting fixed.
              Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    final role = ref.watch(myBikeNativeController.select((value) => value.isRole));
                    return  role == null ? ProgressIndicatorView() : role == false ? _bikeListView() : Expanded(child: VehicleAdminScreen());
                  },
              )],
          ),
        ),
      ),
    );
  }

  /*=============================================title Heading Bar=======================================*/
  Widget _titleHeadingBar() {
    return Row(
      children: [
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final userName =  ref.watch(myBikeNativeController.select((value) => value.userName));
            return InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  AccountSettingScreen(_appVersion)));
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                radius: 18.r,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0.r),
                  child: text(title: '$userName',fontSize: 20.sp, color: blueColor, fontWeight: FontWeight.w500)),),
            );  },
        ),
        20.pw,
        Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
         final isRole =  ref.watch(myBikeNativeController.select((value) => value.isRole));
              return text(title:  isRole == false ? LocaleKeys.keyMyBike.tr() : LocaleKeys.keyAdmin.tr(), maxLines:1,fontSize: 20.sp, color: blueColor, fontWeight: FontWeight.w500);
            },
        ),
        10.pw,
        Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final isRole =  ref.watch(myBikeNativeController.select((value) => value.isRole));
              final bikeAdmin = ref.watch(bikeAdminController.notifier);
              final visibility = ref.watch(userPermController.select((value) => value.isBikeAdminViewAllowed));
              return Visibility(
                visible: visibility,
                child: InkWell(
                    onTap: () async {
                      bikeAdmin.setErrorBox(false);
                      bikeAdmin.setButtonColor(false);
                      limit = 10 ;
                      start = 0;
                      if(isRole == true){
                        await  AppUtils.setString(key: Constants.ROLE, value: Constants.MY_BIKES_VIEW);
                        ref.watch(myBikeNativeController.notifier).setHomePageView(false);
                      } else {
                        await AppUtils.setString(key: Constants.ROLE, value: Constants.BIKE_ADMIN_VIEW);
                        ref.watch(myBikeNativeController.notifier).setHomePageView(true);
                      }
                    },
                    child: Image.asset( isRole == false ? icScanner : icAdmin, scale: isRole == false ? 2.8.h : 3.1.h)),
              );
            },
        ),
        Spacer(),
        BleLocListener(),
      ],
    );
  }

/*============================================bike List View=====================================*/
  Widget _bikeListView(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Expanded(
          child:  ref.watch(myBikeAPIController).when(
              loading: ()=> Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ProgressIndicatorView(),
                    10.ph,
                    text(title: LocaleKeys.keyLoadingBikes.tr() , fontSize: 20.sp, fontWeight: FontWeight.w500, color: blueColor)
                  ],
                ),
              ),   error: (error,_) => buildErrorWidget(error),
              data: (bikeList) {
            return RefreshIndicator(
              color: blueColor,
              key: _refreshIndicatorKey,
              onRefresh: () {
                start = 0;
                limit = 10;
                //TODO TRY WITH REFRESH
                log('in_refresh');
                return ref.read(myBikeAPIController.notifier).getAllBikes(start: start, limit: limit);
              },
              child: ListView(
                controller: _scrollController,
                children: <Widget>[
                ListView.builder(
                    itemCount: bikeList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context,int index){
                      final BikeData bikeData = bikeList[index];
                      return InkWell(
                        onTap: () async {
                         await  AppUtils.setString(key:Constants.SELECTED_BIKE_META, value : json.encode(bikeData));
                         WidgetsBinding.instance.addPostFrameCallback((_){
                           Navigator.pushAndRemoveUntil(this.context, MaterialPageRoute(builder: (context) =>
                               BottomNavBar(bikeData : bikeData, isStartService: false)), (Route<dynamic> route) => false);

                         });
                       },
                        child: Container(
                            padding: EdgeInsets.only(top: 20.h,left: 20.w),
                            margin: EdgeInsets.only(top: 5.h ,bottom: 25.h),
                            decoration: BoxDecoration(
                                color: whiteColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color.fromRGBO(232,239,251,1.0).withOpacity(0.5),
                                      spreadRadius: 6,
                                      blurRadius: 2.0
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10.r)
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(child: text(title: bikeData.friendlyName != "" ? bikeData.friendlyName : bikeData.name, fontSize: 15.sp, color: greyBoldColor, fontWeight: FontWeight.w500)),
                                    10.ph,
                                    bikeData.bike_state == BIKE_STATE.UNLOCKED ? Image.asset(icUnlock,scale: 1.8,) : Image.asset(icLock,scale: 1.8,),
                                    5.ph,
                                    Row(
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (bounds) => const LinearGradient(
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.bottomRight,
                                            colors: [Color.fromRGBO(111, 145, 178, 1.0), Color.fromRGBO(57, 79, 98, 1.0)],
                                          ).createShader(bounds),
                                          child: text(
                                              color: whiteColor,
                                              title: bikeData.bike_state == BIKE_STATE.UNLOCKED ? LocaleKeys.keyUnlocked.tr() : LocaleKeys.keyLocked.tr(),
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                    //TODO UNCOMMENT This when we will implement the scanner part in SDK
                                    // 5.ph,
                                    // text(title: 'In range to start', fontSize: 12.sp, color: greyLightColor, fontWeight: FontWeight.w500),
                                     12.ph,
                                  ],
                                ),
                                Positioned(
                                 bottom: 0.0,
                                  right: 0.0,
                                  child: SvgPicture.asset(
                                    fit: BoxFit.contain,
                                    height : MediaQuery.of(context).size.height /6.5,
                                    'assets/images/ic_blue_bike_cropped.svg',
                                  ),
                                )
                              ],
                            )

                        ),
                      );

                    }),
                  Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final visibility = ref.watch(myBikeRepoProvider).paginatedLoader;
                  return Visibility(
                    visible: visibility,
                    child: CupertinoActivityIndicator(
                    radius: 12.r,
                    animating: true,color: blueColor,));
                    },
                  ),
                  ],
              ),
            );
          })

            ,
        );
      },
    );
  }


  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.dispose();
}

}
