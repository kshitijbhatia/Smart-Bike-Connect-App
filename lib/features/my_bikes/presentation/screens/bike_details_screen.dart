import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:smartbike_flutter/app_utils/app_utils.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/assets.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/controllers/my_bike_controller.dart';
import 'package:smartbike_flutter/features/settings/presentation/controllers/setting_controller.dart';
import 'package:smartbike_flutter/generated/locale_keys.g.dart';
import 'package:smartbike_flutter/smartbike_database/smartbike_db_repo.dart';
import 'package:smartbike_flutter/widgets/common_ui_methods.dart';
import 'package:smartbike_flutter/widgets/gredient_border.dart';
import 'package:smartbike_flutter/widgets/viewport_painter.dart';

import '../../../../main.dart';
import '../../../../widgets/shimmer_effect.dart';


class BikeDetailScreen extends ConsumerStatefulWidget {
  final BikeData bikeData;
  BikeDetailScreen({required this.bikeData});

  @override
  ConsumerState<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends ConsumerState<BikeDetailScreen>{

  double totalDistance = 0.0;

  LatLng? _currentLocation;
  LatLng? _lastParkedLocation;
  String timeDifference = '';

  final _platform = const MethodChannel(SMARTBIKE_PLUGIN);
  String buttonText = "${LocaleKeys.keySlideTo.tr()}" "${LocaleKeys.keyLock.tr()}", buttonArrow = icForwardArrow;
  BikeData? bikeData;
  late Widget lastParkedLocationMarkerWidgets ,  currentLocationMakerWidget;
  Key mapImageNewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    bikeData = widget.bikeData;
    if(bikeData!.LastParkedLocation.isEmpty){
      ref.read(myBikeNativeController.notifier).fetchBikeLastParkedLocFromDB(bikeData!.id);
    }
  }

  /*=======================================calculate Distance in Km =====================================*/

  double _calculateDistance({lat1, lon1, lat2, lon2}) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    totalDistance = 12742 * asin(sqrt(a));
    developer.log('total_distance_is ${totalDistance.toStringAsFixed(2)}');
    return totalDistance;
  }

  /*=======================================fetch Address From Lat Long=====================================*/

  Future<String> _fetchAddressFromLatLong(LatLng location) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(location.latitude, location.longitude,);
      if (placeMarks.isNotEmpty) {
        Placemark placeMark = placeMarks[0];
        String address = '${placeMark.name},${placeMark.locality}';
        return address;
      }
      return '';
    } catch (e) {
      developer.log(e.toString());
      return '';
    }
  }

  void _formulateLastParkedLocParams(dynamic LastParkedLocation) async{

    _lastParkedLocation =  LatLng( double.parse(LastParkedLocation['latitude']),double.parse(LastParkedLocation['longitude']));

    if(_currentLocation != null){
      _calculateDistance(lat1: _currentLocation!.latitude,lon1: _currentLocation!.longitude,lat2: double.parse(LastParkedLocation['latitude']),lon2: double.parse(LastParkedLocation['longitude']));
    }

    developer.log('lastParkedLocation ${LastParkedLocation['timestamp']} ${LatLng(double.parse(LastParkedLocation['latitude']), double.parse(LastParkedLocation['longitude'])) }');

    String locTimeStamp = LastParkedLocation['timestamp'];
    if(locTimeStamp.contains('.')){
      locTimeStamp = locTimeStamp.substring(0, locTimeStamp.indexOf('.'));
    }

    timeDifference = AppUtils.calculateTimeDifference(DateTime.now().millisecondsSinceEpoch, int.parse(locTimeStamp) * 1000);
    String address = await  _fetchAddressFromLatLong(_lastParkedLocation!);
    String completeAddress = address +'/'+timeDifference;
    if(mounted)
    ref.read(myBikeNativeController.notifier).updateBikeLastParkedAddress(completeAddress);
  }


  @override
  Widget build(BuildContext context) {
    return bodyView();
  }

  /*============================================body View======================================*/

  Widget bodyView() {
    return Column(children: [
      20.ph,
      Expanded(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final sbmStatus = ref.watch(myBikeNativeController.select((value) => value.sbmStatus));
              return Container(
                margin: EdgeInsets.only(left: 20.w, right: 20.w),
                decoration: BoxDecoration(
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: sbmStatus == SBM_STATE.DISCONNECTED
                            ? [
                                const Color.fromRGBO(255, 194, 176, 1.0),
                                const Color.fromRGBO(239, 152, 49, 1.0),
                              ]
                            : [
                                const Color.fromRGBO(6, 227, 68, 1.0),
                                const Color.fromRGBO(1, 164, 255, 1.0),
                              ]),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(
                  children: [
                    _warningsView(),
                    _vehicleImageView(),
                    _bikeVicinityView(),
                    _bikeStatusSheet(),
                    _mapView(),
                    _vehicleLastParkedLocationView(),
                    _lockUnlockButtonView()
                  ],
                ),
              );
            },
          ))
    ]);
  }
  /*============================================_bike Status Sheet================================*/

  Widget _bikeStatusSheet(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child){
        final bikeStatusText = ref.watch(myBikeNativeController.select((value) => value.bikeStateText));
        return Visibility(
          visible: bikeStatusText != '',
          child: Container(
            alignment: Alignment.center,
            color: greyColor,
            height: 30.h,
            child: text(title: bikeStatusText,
                fontSize: 12.sp,maxLines: 1,
                fontWeight: FontWeight.w700,
                color: blackColor,textAlign: TextAlign.center),
          ),
        );
      },
    );
 }

 Widget _warningsView(){

    return Consumer(
     builder: (BuildContext context, WidgetRef ref, Widget? child){

       final blePermStatus = ref.watch(myBikeNativeController.select((value) => value.isBlePermGranted));
       final locPermStatus = ref.watch(myBikeNativeController.select((value) => value.isLocPermGranted));
       final bleStatus = ref.watch(myBikeNativeController.select((value) => value.isBleOnOffStatus));
       final locStatus = ref.watch(myBikeNativeController.select((value) => value.isLocOnOffStatus));
       final noAdvBleWarning = ref.watch(myBikeNativeController.select((value) => value.noScanBLEWarning));
       final smartnessCheck =  ref.watch(settingController.select((value) => value.smartnessValue));
       final sbmStatus = ref.watch(myBikeNativeController.select((value) => value.sbmStatus));

       String message = '';

       if(noAdvBleWarning){
         message = LocaleKeys.keyNoAdvBleWarning.tr();
       }if(!bleStatus){
         message = LocaleKeys.keyBleOff.tr();
       } if(!locStatus){
         message = LocaleKeys.keyLocOff.tr();
       } if(!bleStatus && !locStatus){
         message = LocaleKeys.keyBleLocOff.tr();
       } if(!blePermStatus){
         message = LocaleKeys.keyBlePermOff.tr();
       } if(!locPermStatus){
         message = LocaleKeys.keyLocPermOff.tr();
       } if(!blePermStatus && !locPermStatus){
         message = LocaleKeys.keyBleLocPermOff.tr();
       }else if(smartnessCheck == 0 && sbmStatus == SBM_STATE.CONNECTED){
         message = LocaleKeys.keySmartnessDisabledWarning.tr();
       }

       return Visibility(
         visible: noAdvBleWarning || !bleStatus || !locStatus || !blePermStatus || !locPermStatus || (smartnessCheck == 0 && sbmStatus == SBM_STATE.CONNECTED),
         child: Container(
           alignment: Alignment.center,
           decoration: BoxDecoration(
               borderRadius: BorderRadius.only(
                 topRight: Radius.circular(15.r),
                 topLeft: Radius.circular(15.r),
               ),
               color: errorColor
           ),
           height: noAdvBleWarning || smartnessCheck == 0 ? 40.h : 30.h,
           child: text(title: message,
               fontSize: 12.sp, maxLines: noAdvBleWarning || smartnessCheck == 0 ? 2 : 1,
               fontWeight: FontWeight.w700,
               color: whiteColor,textAlign: TextAlign.center),
         ),
       );
     },
    );
 }

  /*============================================in /out Range View=====================================*/
  Widget _bikeVicinityView(){
    return  Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final bikeVicinity = ref.watch(myBikeNativeController.select((value) => value.bikeVicinity));
        String rangeText= '';
        if(bikeVicinity == 'IN_RANGE'){
          rangeText = LocaleKeys.keyInRange.tr();
        }else if(bikeVicinity == 'NOT_SEEN') {
          rangeText = LocaleKeys.keyNotSeen.tr();
        } else  {
          rangeText = LocaleKeys.keyOutOfRange.tr();
        }
        return Container(
          alignment: Alignment.center,
          color: offWhiteColor,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 5.h),
          child: text(
              textAlign: TextAlign.center,
              title: rangeText,
              fontWeight: FontWeight.w800,
              color: blueColor,
              fontSize: 16.sp),
        );
      },
    );
  }

  /*============================================vehicle Last Parked Location View======================================*/
  Widget  _vehicleLastParkedLocationView(){
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
       final addressValue = ref.watch(myBikeNativeController.select((value) => value.lastParkedAddress));
       String address = '';
       if(addressValue != ''){
         address = addressValue.split('/').first;
         timeDifference = addressValue.split('/')[1];
       }
        return Visibility(
          visible: address != '',
          child: Container(
            alignment: Alignment.center,
            color: offWhiteColor,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 5.h,bottom: 5.h),
            child: InkWell(
              onTap: (){
                openMap(context: context,lat: _lastParkedLocation!.latitude,lng: _lastParkedLocation!.longitude);
              },
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 5.0.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    text(
                      maxLines: 1,
                        textAlign: TextAlign.start,
                        title: "${LocaleKeys.keyLastParked.tr()}  ",
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        fontSize: 12.sp),
                    Flexible(
                      flex: 2,
                      child: text(
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          title: "$address ",
                          fontWeight: FontWeight.w500,
                          color: blueColor,
                          decoration : TextDecoration.underline,
                          fontSize: 12.sp),
                    ),
                    text(
                        maxLines: 1,
                        title: "$timeDifference",
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                        fontSize: 12.sp),
                  ],
                ),
              )
              ,
            ),
          ),
        );
      },
    );
}

  /*============================================vehicle Image View======================================*/

  Widget _vehicleImageView() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final sbmStatus = ref.watch(myBikeNativeController.select((value) => value.sbmStatus));
        return Column(
          children: [

            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.5,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(sbmStatus == SBM_STATE.DISCONNECTED ? icOrangeBg : icGreenBg),
                            fit: BoxFit.fill)),
                    child: Transform.translate(
                      offset: Offset(0.h,-6.h),
                      child: SvgPicture.asset(
                        'assets/images/ic_home_bike.svg',
                        fit: BoxFit.contain,
                      ),
                    )),
                Positioned(
                  bottom: 5.0.h,
                  child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      String buttonState = ref.watch(myBikeNativeController.select((value) => value.buttonState));
                      //developer.log("buttonState $buttonState");
                      return Visibility(
                        visible: buttonState != '' ,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              buttonState == Constants.SEND_LOCK ? icUnLockGradient : icLockGradient,
                              scale: 3.2.h,
                            ),
                            15.pw,
                            Flexible(
                              child: headingText(
                                gradientColor: buttonState != Constants.SEND_LOCK ?
                                [
                                  Color.fromRGBO(37, 6, 227, 1.0),
                                  Color.fromRGBO(113, 1, 255,  1.0),
                                ]
                                 :[
                                  Color.fromRGBO(91, 68, 174, 1.0),
                                Color.fromRGBO(49, 222, 149,  1.0),
                            ],
                            title: buttonState == Constants.SEND_LOCK ? LocaleKeys.keyUnlocked.tr() : LocaleKeys.keyLocked.tr(),
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900), ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  /*============================================map View======================================*/

  Widget _mapView() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final lastParkedLocation = ref.watch(myBikeNativeController.select((value) => value.lastParkedLocation));
        final locPermStatus = ref.watch(myBikeNativeController.select((value) => value.isLocPermGranted));
        final locStatus = ref.watch(myBikeNativeController.select((value) => value.isLocOnOffStatus));
        _currentLocation = ref.watch(currentLocationController.select((value) => value.currentLocation));
        String buttonState = ref.watch(myBikeNativeController.select((value) => value.buttonState));

        //TODO VERIFY THIS
        if (lastParkedLocation != '') {

          developer.log('gotLastParkedLocation $lastParkedLocation');
          ///Updating bikeParkedLoc in DB
          ref.read(dbRepoProvider).updateBikeLastParkedLocation(widget.bikeData.id, jsonEncode(lastParkedLocation));
          _formulateLastParkedLocParams(lastParkedLocation);

        }else if(widget.bikeData.LastParkedLocation.isNotEmpty){
          developer.log('initial_lastParkedLoc ${widget.bikeData.LastParkedLocation}');
          _formulateLastParkedLocParams(widget.bikeData.LastParkedLocation);
        }

        developer.log('curr_loc ${_currentLocation} || $locPermStatus || $locStatus || $lastParkedLocation');

        if(_currentLocation != null){

          mapImageNewKey = UniqueKey();

          //_clearMapCacheImage();


        }

        return Flexible(
          child:  (_currentLocation != null || _lastParkedLocation != null ) ?
          Stack(
            children: [
              ClipRRect(
                borderRadius:buttonState == ""? BorderRadius.only(
                  bottomRight: Radius.circular(15.r),
                  bottomLeft: Radius.circular(15.r),
                ):BorderRadius.zero,
                child: MapLayout(
                  controller: MapController(
                    location: (_currentLocation ?? _lastParkedLocation) ??  const LatLng(38.897957, -77.036560),
                    zoom: 14,
                  ),
                  builder: (context, transformer) {
                    if (_lastParkedLocation != null){
                      final lastParkedLocationPosition = transformer.toOffset(_lastParkedLocation!);
                      lastParkedLocationMarkerWidgets  = _buildMarkerWidget(lastParkedLocationPosition);
                      developer.log('createdLastParkedWidget');
                    }
                    if (_currentLocation != null){
                      final currentLocationPosition = transformer.toOffset(_currentLocation!);
                      currentLocationMakerWidget = _buildMarkerWidget(currentLocationPosition,isAssetImage: true);
                      developer.log('createdCurrentLocationMakerWidget');
                    }
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          children: [
                            TileLayer(
                              builder: (context, x, y, z) {
                                final tilesInZoom = pow(2.0, z).floor();

                                while (x < 0) {
                                  x += tilesInZoom;
                                }
                                while (y < 0) {
                                  y += tilesInZoom;
                                }
                                x %= tilesInZoom;
                                y %= tilesInZoom;
                                return CachedNetworkImage(
                                  // key: mapImageNewKey,
                                  // cacheManager: CacheManager(
                                  //     Config(
                                  //       'mapImage',
                                  //       stalePeriod: const Duration(seconds: 2),
                                  //       //one week cache period
                                  //     )
                                  // ),
                                  imageUrl: googleUrl(z, x, y),
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            CustomPaint(
                              painter: ViewportPainter(
                                transformer.getViewport(),
                              ),
                            ),
                            if (_currentLocation != null)  currentLocationMakerWidget,
                            if (_lastParkedLocation != null) lastParkedLocationMarkerWidgets,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                right: 0.0,
                bottom: 0.0,
                child: InkWell(
                  onTap: (){

                    if(_currentLocation != null && _lastParkedLocation != null){
                      openDistanceMap(context: context,startLat: _currentLocation!.latitude,startLng:_currentLocation!.longitude,endLat:_lastParkedLocation!.latitude, endLng: _lastParkedLocation!.longitude);
                    }
                    else if(_currentLocation != null){
                      openMap(context: context,lat: _currentLocation!.latitude,lng: _currentLocation!.longitude);
                    }
                  },
                  child: Visibility(
                    visible: (_currentLocation != null || _lastParkedLocation != null) ,
                    child: Container(
                      height: MediaQuery.of(context).size.height* 0.1,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Card(
                        elevation: 5,
                        surfaceTintColor: Colors.white,
                        margin: EdgeInsets.all(15.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        child: Image.asset(icMap,scale: 2.8.h,),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ) : !locPermStatus || !locStatus ?
          ClipRRect(
            borderRadius: buttonState == "" ? BorderRadius.only(
              bottomRight: Radius.circular(15.r),
              bottomLeft: Radius.circular(15.r),
            ) : BorderRadius.zero,
            child: MapLayout(
              controller: MapController(
                location: const LatLng(38.897957, -77.036560),
                zoom: 14,
              ),
              builder: (context, transformer) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        TileLayer(
                          builder: (context, x, y, z) {
                            final tilesInZoom = pow(2.0, z).floor();
                            while (x < 0) {
                              x += tilesInZoom;
                            }
                            while (y < 0) {
                              y += tilesInZoom;
                            }
                            x %= tilesInZoom;
                            y %= tilesInZoom;
                            return CachedNetworkImage(
                              imageUrl: googleUrl(z, x, y),
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        CustomPaint(
                          painter: ViewportPainter(
                            transformer.getViewport(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ) : Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  _clearMapCacheImage() async{
    await DefaultCacheManager().removeFile('mapImage');
  }


  /*===========================================lock Unlock Button View======================================*/

  Widget _buildMarkerWidget(Offset pos, { bool isAssetImage = false}) {
    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 24,
      width: 48,
      height: 48,
      child: /*Tooltip(
        showDuration: const Duration(seconds: 5),
        triggerMode: TooltipTriggerMode.tap,
        decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(5)),
        textStyle: const TextStyle(color: Colors.black),
        message: 'You have clicked a marker!',
        child:*/ isAssetImage == true ? Image.asset(icYou,scale: 3.5.h,) :  Icon(Icons.location_pin,color: Colors.red,size: 25.h,),
    // ),
    );
  }


  /*===========================================lock Unlock Button View======================================*/

  Widget _lockUnlockButtonView() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final bikeController = ref.watch(myBikeNativeController.notifier);
        String buttonState = ref.watch(myBikeNativeController.select((value) => value.buttonState));
        bool isSlide = ref.watch(myBikeNativeController.select((value) => value.isSliding));
        double _slidePosition = ref.watch(myBikeNativeController.select((value) => value.slidePosition));
        if (buttonState ==  Constants.SEND_LOCK) {
          buttonText = "${LocaleKeys.keySlideTo.tr()}" "${LocaleKeys.keyLock.tr()}";
          buttonArrow = icForwardArrow;
        } else {
          buttonText = "${LocaleKeys.keySlideTo.tr()}" "${LocaleKeys.keyUnlock.tr()}";
          buttonArrow = icBackArrow;
        }

        if(buttonState ==  Constants.SEND_LOCK){
          ref.read(myBikeNativeController.notifier).updateBikeState(widget.bikeData.id, 0);
        }else if(buttonState ==  Constants.SEND_UNLOCK){
          ref.read(myBikeNativeController.notifier).updateBikeState(widget.bikeData.id, 1);
        }
        return Visibility(
          visible: buttonState != '' ,
          child: GestureDetector(
            onTap: () async {},
            onHorizontalDragStart: (details) {
              bikeController.setSlideAnimation(true);
            },
            onHorizontalDragUpdate: (details) {
                bikeController.setSlidePosition(1.0) ;
            },
            onHorizontalDragEnd: (details) async {
               bikeController.setSlideAnimation(false);
               bikeController.setSlidePosition(0.0) ;
                await _platform.invokeMethod(Constants.CHANGE_STATE_OF_BIKE, "");
            },
            child: Container(
              alignment: Alignment.center,
              height: 50.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(15.r),
                    bottomLeft: Radius.circular(15.r)),
                 gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: buttonState ==  Constants.SEND_LOCK?[
                    const Color.fromRGBO(109, 69, 194, 1.0),
                    const Color.fromRGBO(47, 64, 126, 1.0),
                  ]:[
                    const Color.fromRGBO(73, 201, 73, 1.0),
                    const Color.fromRGBO(90, 108, 191, 1.0),
                  ]),
              ),
              child: AnimatedContainer(
                alignment: isSlide ? buttonState ==  Constants.SEND_LOCK ? Alignment.centerRight: Alignment.centerLeft : Alignment.center,
                duration: Duration(milliseconds: 800),
                curve: Curves.ease,
                transform: Matrix4.translationValues(_slidePosition, 0.0, 0.0),
                child: Shimmer.fromColors(
                  direction: buttonState ==  Constants.SEND_LOCK ? ShimmerDirection.ltr : ShimmerDirection.rtl,
                  baseColor: whiteColor ,
                  highlightColor: Colors.grey.shade600,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        buttonArrow,
                        scale: 2.5.h,
                      ),
                      10.pw,
                      Flexible(
                        child: text(
                            title: buttonText,
                            fontSize: 16.sp,
                            color: whiteColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  dispose() {
    super.dispose();
    developer.log('bike_detail_screen_disposed');
  }
}
