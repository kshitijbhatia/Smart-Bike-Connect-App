import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:device_preview/device_preview.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:battery_info/model/iso_battery_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbike_flutter/constants/app_colors.dart';
import 'package:smartbike_flutter/constants/strings.dart';
import 'package:smartbike_flutter/features/authentication/presentation/screens/create_pin_screen.dart';
import 'package:smartbike_flutter/features/authentication/presentation/screens/enter_pin_screen.dart';
import 'package:smartbike_flutter/features/authentication/presentation/screens/new_login_screen.dart';
import 'package:smartbike_flutter/features/my_bikes/data/method_channel_events/method_channel_events_trigger.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/bike_admin_screen.dart';
import 'package:smartbike_flutter/features/my_bikes/presentation/screens/new_my_bike_list_screen.dart';
import 'package:smartbike_flutter/generated/codegen_loader.g.dart';
import 'package:smartbike_flutter/widgets/notification_service.dart';
import 'package:smartbike_flutter/widgets/toast.dart';

import 'features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'features/my_bikes/presentation/screens/bottom_nav_bar.dart';
import 'features/service/user_perm_controller.dart';

const String SMARTBIKE_PLUGIN = 'smartbike_plugin';
const MethodChannel _channelSmartBike = MethodChannel(SMARTBIKE_PLUGIN);
bool? batteryStatus = null;
int notificationCount = 0;
SharedPreferences? sharedPreferences;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final sharedPreferencesProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());


void main() async {
  ///To catch errors inside where flutter won't catch
  ///ex. onPressed, this runZone is added
  runZonedGuarded<Future<void>>(() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();

  //FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  //Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true, information: ['Application version', '${Constants.APPLICATION_VERSION}'],);
  //   return true;
  // };

  ///Disabling crashlytics in debug mode.
  if(kDebugMode){
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  sharedPreferences = await SharedPreferences.getInstance();
  await NotificationService().init();
  await NotificationService().requestIOSPermissions();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));

  runApp(
    //DevicePreview(builder: (context) =>
      EasyLocalization(supportedLocales: const [Locale('en'), Locale('fr',)],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      assetLoader: const CodegenLoader(),
      child:  ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences!),
          ],
          child: MyApp(),
      ),
    ),
  //),
  );


  _channelSmartBike.setMethodCallHandler(MethodChannelEventsTrigger.handleNativeCallbacks);
  //isolatesCall();

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
      fatal: true,
    );
  }).sendPort);

  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

/*======================================get Battery Info=================================*/

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Widget? screen;

  @override
  void initState() {
    super.initState();

    if(sharedPreferences!.containsKey(Constants.FIRST_TIME_INSTALL)){
      if(sharedPreferences!.getBool(Constants.FIRST_TIME_INSTALL) == true) {
        screen = LoginScreen();
      }else {
        if(sharedPreferences!.containsKey(Constants.SELECTED_BIKE_META)){
          screen = BottomNavBar(
            bikeData: BikeData.fromJson(json.decode(sharedPreferences!.getString(Constants.SELECTED_BIKE_META)!)),
            isStartService: true,
          );
        }else{
          screen = MyBikeList();
        }
      }
    }else{
      screen = LoginScreen();
    }

    // if (sharedPreferences!.containsKey(Constants.FIRST_TIME_INSTALL)) {
    //   if (sharedPreferences!.getBool(Constants.FIRST_TIME_INSTALL) == true) {
    //     screen = LoginScreen();
    //   } else {
    //     if (sharedPreferences!.containsKey(Constants.SELECTED_BIKE_META)) {
    //       screen = BottomNavBar(
    //         bikeData: BikeData.fromJson(json.decode(sharedPreferences!.getString(Constants.SELECTED_BIKE_META)!)),
    //         isStartService: true,
    //       );
    //     } else {
    //       screen = MyBikeList();
    //     }
    //   }
    // } else {
    //   screen = LoginScreen();
    // }
    _initMethod();
  }

  _initMethod() async {
    await ref.read(userPermController.notifier).initPermMapping();
    await  Future.delayed(Duration(seconds: 1)).then((value) => FlutterNativeSplash.remove());
    ///Not working in iOS, has to find a relevant solution for it as well
    ///TEST THIS TOMORROW
    if(Platform.isAndroid){
      Future.delayed(Duration(seconds: 3),(){
        log('starting_isolate_at_delay');
       // isolatesCall();
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // useInheritedMediaQuery: true,
          builder: DevicePreview.appBuilder,
          title: 'SBMConnect',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.indigo,
          ),
          // home: screen,
          home: EnterPinScreen(),
          // home: CreatePinScreen(),
        );
      },
    );
  }

  @pragma('vm:entry-point')
  static void isolatesCall() async {
    final receivePort = ReceivePort();
    await FlutterIsolate.spawn(_getBatteryInfo, receivePort.sendPort);
    receivePort.listen((message) {
      log('Response: ${message}');
    });
  }


  ///A notification is triggered when battery of the phone reaches <= 30
  static void  _getBatteryInfo(SendPort sendPort) async {

    if (Platform.isAndroid) {

      BatteryInfoPlugin().androidBatteryInfoStream.listen((AndroidBatteryInfo? androidBatteryInfo) {
        bool isCharging = androidBatteryInfo?.chargingStatus == ChargingStatus.Charging;

        if (batteryStatus != null) {
          if (batteryStatus != isCharging) {
            batteryStatus = isCharging;
            notificationCount = 0;
          }
        } else {
          batteryStatus = isCharging;
        }


        if (androidBatteryInfo!.batteryLevel! <= 30 && !isCharging) {
          NotificationService().cancelAllNotifications();
          notificationCount++;
          if (notificationCount == 1) {
            NotificationService().showNotifications();
          }
        }
        sendPort.send('android_battery: ${androidBatteryInfo.batteryLevel} ${isCharging} ${notificationCount}');
      });

    } else {

      BatteryInfoPlugin().iosBatteryInfoStream.listen((IosBatteryInfo? iosBatteryInfo) {
        bool isCharging = iosBatteryInfo?.chargingStatus == ChargingStatus.Charging;

        if (batteryStatus != null) {
          if (batteryStatus != isCharging) {
            batteryStatus = isCharging;
            notificationCount = 0;
          }
        } else {
          batteryStatus = isCharging;
        }

        if (iosBatteryInfo!.batteryLevel! <= 30 && !isCharging) {
          NotificationService().cancelAllNotifications();
          notificationCount++;
          if (notificationCount == 1) {
            NotificationService().showNotifications();
          }
        }
        sendPort.send('iOS_Battery: ${iosBatteryInfo.batteryLevel} ${isCharging} ${notificationCount}');
      });
    }
  }

}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  late String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _counter = 0;

  final _platform = const MethodChannel(SMARTBIKE_PLUGIN);

  String BIKE_VICINITY = '';
  String SBM_STATE = 'DISCONNECTED';
  String BIKE_STATE = 'UNKNOWN';
  String BUTTON_STATE = 'CHANGE_STATE_OF_BIKE';
  String SMARTNESS = 'ENABLE';
  String SBM_VERSION = "";
  dynamic lastParkedLoc = '';
  bool _isLowerAndroid = false;

  List<Permission> permissionList = [];

  void _incrementCounter() async {
    final version = await _platform.invokeMethod<String>('nativeTest');
    print('version $version');
  }

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _initiateOperations();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addObserver(this);
  }

  void _initiateOperations() async {
    if (Platform.isAndroid) {
      _isLowerAndroid = await _platform.invokeMethod('checkAndroidVersion');
      print('AndroidVersion $_isLowerAndroid');
    }

    _requestPermissions(_isLowerAndroid);
    _channelSmartBike.setMethodCallHandler(handleScanMethod);
  }

  _requestPermissions(bool androidVersion) async {
    if (!androidVersion && Platform.isAndroid) {
      bool isBleConPerm = await Permission.bluetoothConnect.isGranted;
      bool isBleAdvPerm = await Permission.bluetoothAdvertise.isGranted;
      bool isBleScanPerm = await Permission.bluetoothScan.isGranted;

      if (!isBleConPerm || !isBleAdvPerm || !isBleScanPerm) {
        permissionList.add(Permission.bluetoothScan);
        permissionList.add(Permission.bluetoothAdvertise);
        permissionList.add(Permission.bluetoothConnect);
      }
    } else {
      if (Platform.isIOS) {
        bool isBlePerm = await Permission.bluetooth.isGranted;
        if (!isBlePerm) {
          permissionList.add(Permission.bluetooth);
        }
      }
    }

    bool isLocPerm = await Permission.locationWhenInUse.isGranted;

    if (!isLocPerm) {
      permissionList.add(Permission.locationWhenInUse);
    }

    if (permissionList.isNotEmpty) {
      Map<Permission, PermissionStatus> permissionMap =
          await permissionList.request();

      if (permissionMap[Permission.locationWhenInUse] != null &&
          permissionMap[Permission.locationWhenInUse]!.isGranted == false) {
        if (!androidVersion) {
          if (!permissionMap[Permission.bluetoothScan]!.isGranted) {
            bool canOpenSetting = await openAppSettings();
            log('$canOpenSetting');
            return;
          }
        }
      } else {
        if (Platform.isIOS &&
            permissionMap[Permission.bluetooth] != null &&
            permissionMap[Permission.bluetooth]!.isGranted == false) {
          bool canOpenSetting = await openAppSettings();
          log('$canOpenSetting');
          return;
        }
      }
    }

    log('startingServiceFromFlutter');
    await _platform.invokeMethod(Constants.START_SERVICE, true);
    setState(() {});
  }

  Future<dynamic> handleScanMethod(MethodCall call) async {
    switch (call.method) {
      case Constants.SBM_CONNECTED:
        log('FlutterSide SBM_CONNECTED');
        SBM_STATE = 'CONNECTED';
        setState(() {});
        return true;

      case Constants.SBM_DISCONNECTED:
        log('FlutterSide SBM_DISCONNECTED');
        SBM_STATE = 'DISCONNECTED';
        SBM_VERSION = "";
        setState(() {});
        return true;

      case Constants.NEW_BIKE_STATE:
        dynamic newBikeState = call.arguments;
        BIKE_STATE = newBikeState.toString();
        log('newBikeState $newBikeState  | $BIKE_STATE');
        setState(() {});
        return;

      case Constants.NEW_BUTTON_STATE:
        dynamic newButtonState = call.arguments;
        BUTTON_STATE = newButtonState.toString();
        log('newButtonState $newButtonState  | $BUTTON_STATE');
        _updateValue(BUTTON_STATE);
        //setState(() {});
        return;

      case Constants.LAST_PARK_LOCATION:
        dynamic lastParkedLocation = call.arguments;
        lastParkedLoc = call.arguments;
        log('lastParkedLocation $lastParkedLocation');
        setState(() {});
        return;

      case Constants.BIKE_VICINITY:
        BIKE_VICINITY = call.arguments;
        setState(() {});
        return;

      case Constants.LEARN_MODE_RESPONSE:
        bool learnModeResponse = call.arguments;
        if (learnModeResponse) {
          showToast('Learn Mode Sent', warning: false);
        } else {
          showToast('Failed to Send Learn Mode', warning: true, duration: true);
        }
        return;

      case Constants.SMARTNESS_CHANGED:
        String smartnessResponse = call.arguments;
        if (smartnessResponse != 'FAILED') {
          SMARTNESS = smartnessResponse;
        } else {
          showToast('Failed to change Smartness',
              warning: true, duration: true);
        }
        return;

      case Constants.SBM_FIRMWARE_VERSION:
        SBM_VERSION = call.arguments;
        setState(() {});
        return;

      case Constants.FAILED_TO_CHANGE_BIKE_STATE:
        dynamic failedBikeState = call.arguments;
        showToast(failedBikeState, warning: true);
        log('failedToChangeBikeState $failedBikeState');
        setState(() {});
        return;

      case Constants.FAILED_TO_ADVERTISE:
        SBM_STATE = 'FAILED_TO_ADVERTISE';
        setState(() {});
        return;
    }
  }

  _updateValue(String newValue) {
    setState(() {
      BUTTON_STATE = newValue;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('app in resumed');
        break;

      case AppLifecycleState.inactive:
        print('app in inactive');
        break;
      case AppLifecycleState.paused:
        print('app in paused');

        break;
      case AppLifecycleState.detached:
        print('app in detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      widget.title = "Flutter SmartBike Demo 1.1v";
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _textField(context),
                Visibility(
                    visible: SBM_VERSION != "",
                    child: const SizedBox(height: 15)),
                Visibility(
                    visible: SBM_VERSION != "",
                    child: Text('SBM VERSION $SBM_VERSION')),
                const SizedBox(height: 15),
                Text(SBM_STATE),
                const SizedBox(height: 15),
                Visibility(
                    visible: BIKE_VICINITY != '', child: Text(BIKE_VICINITY)),
                const SizedBox(height: 15),
                Text(BIKE_STATE),
                const SizedBox(height: 20),
                Flexible(
                  child: ElevatedButton(
                    child: const Text('CONNECT SBM'),
                    onPressed: () async {
                      if (_textEditingController.text.trim().length == 17 ||
                          _textEditingController.text == 'SBM') {
                        Map<String, dynamic> requestBody = {
                          "barcodeID": "180",
                          "macID": _textEditingController.text == 'SBM'
                              ? 'EA:4C:75:F3:F7:4A'
                              : _textEditingController.text.trim(),
                          "encryptionKeyPrimary": "",
                          "encryptionKeySecondary": ""
                        };

                        final status = await _platform.invokeMethod(
                            Constants.CONNECT_TO_SBM, requestBody);
                        log('connectToSBMResponse $status');
                      } else {
                        log('Please Enter valid MACID');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ElevatedButton(
                    child: const Text('DISCONNECT SBM'),
                    onPressed: () async {
                      final status = await _platform.invokeMethod(
                          Constants.DISCONNECT_FROM_SBM, "");
                      log('statusOfDisconnectedSBMCall $status');
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ElevatedButton(
                    child: Text(BUTTON_STATE),
                    onPressed: () async {
                      await _platform.invokeMethod(
                          Constants.CHANGE_STATE_OF_BIKE, "");
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: SBM_STATE == 'CONNECTED',
                  child: Flexible(
                    child: ElevatedButton(
                      child: const Text('SEND LEARN MOE'),
                      onPressed: () async {
                        int status = await _platform.invokeMethod(
                            Constants.SEND_LEARN_MODE, "");
                        if (status == 301) {
                          showToast('Please turn on the Ignition first!',
                              warning: true, duration: true);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: SBM_STATE == 'CONNECTED',
                  child: Flexible(
                    child: ElevatedButton(
                      child: Text(SMARTNESS),
                      onPressed: () async {
                        bool status = await _platform.invokeMethod(
                            Constants.CHANGE_SMARTNESS, SMARTNESS);
                        if (!status) {
                          showToast('Failed to change Smartness',
                              warning: true, duration: true);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                    visible: lastParkedLoc != '',
                    child: Flexible(child: Text(lastParkedLoc)))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(BuildContext context) => Container(
      height: 34,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
          color: whiteColor, borderRadius: BorderRadius.circular(6)),
      child: TextField(
        controller: _textEditingController,
        maxLength: 17,
        cursorColor: Colors.blue,
        enableInteractiveSelection: true,
        decoration: const InputDecoration(
          counterText: '',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          hintText: 'MAC ID',
          border: InputBorder.none,
        ),
      ));
}
