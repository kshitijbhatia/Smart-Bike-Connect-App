import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {

    //Initialization Settings for Android
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/app_icon');

    //Initialization Settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,);
  }

  Future<void> requestIOSPermissions() async {
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

   NotificationDetails platformChannelSpecifics = NotificationDetails(android: AndroidNotificationDetails(
     'SBMConnect',
     'Low Battery',
     channelDescription: 'SBMConnect',
     playSound: true,
     priority: Priority.high,
     importance: Importance.high,
     icon: '@drawable/app_icon',
     largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_battery_alert'),
   ), iOS: DarwinNotificationDetails(
           presentAlert: true,
           presentBadge: true,
           presentSound: true,
       ));

  Future<void> showNotifications() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Low Battery',
      'Please charge your phone',
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }
}

  Future selectNotification(String payload) async {
  }

