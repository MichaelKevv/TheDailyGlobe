import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotification {
  final firebasemessage = FirebaseMessaging.instance;
  Future<void> initNotification() async {
    await firebasemessage.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final token = await firebasemessage.getToken();
    print(token);
  }
}
