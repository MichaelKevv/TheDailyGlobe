import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thedailyglobe/main.dart';
import 'package:thedailyglobe/screen/home/Home.dart';
import 'package:thedailyglobe/screen/theme/Color.dart';
import 'package:thedailyglobe/services/pushnotification.dart';
import 'package:http/http.dart' as http;

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;
      if (notification != null && android != null) {
        if (android.imageUrl.toString() != '' &&
            android.imageUrl.toString() != 'null') {
          http.get(Uri.parse(android.imageUrl.toString())).then((response) {
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(channel.id, channel.name,
                      channelDescription: channel.description,
                      styleInformation: BigPictureStyleInformation(
                        ByteArrayAndroidBitmap(response.bodyBytes),
                      ),
                      channelAction: AndroidNotificationChannelAction.update,
                      enableVibration: true,
                      playSound: true,
                      icon: '@mipmap/ic_launcher'),
                ));
          });
        } else {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    channelDescription: channel.description,
                    channelAction: AndroidNotificationChannelAction.update,
                    enableVibration: true,
                    playSound: true,
                    icon: '@mipmap/ic_launcher'),
              ));
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> requestNotificationPermissions() async {
      await Permission.notification.request();
      final PermissionStatus status = await Permission.notification.status;
      print(status);
      if (status.isGranted) {
        await PushNotification().initNotification();
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
            PageTransition(
                type: PageTransitionType.bottomToTop,
                duration: const Duration(milliseconds: 500),
                alignment: Alignment.center,
                child: Home()),
            (Route<dynamic> route) => false);
      } else if (status.isDenied) {
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }

    return Scaffold(
      backgroundColor: ColorsInt.colorPrimary1,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 0, right: 0),
            child: Text(
              'Welcome to\nThe Daily Globe!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9900000095367432),
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Please set your preferences to \nget the app up and running.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9900000095367432),
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 62,
          ),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: ColorsInt.colorWhite,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't miss our\ntop stories!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Subscribe to our notifications to stay up to date on the latest breaking news.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsInt.colorPrimary2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 46, vertical: 18),
                  ),
                  onPressed: () async {
                    requestNotificationPermissions();
                  },
                  child: Text('Subscribe to Notifications Now'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
