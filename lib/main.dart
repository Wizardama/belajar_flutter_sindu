import 'package:flutter/material.dart';

// Int
import 'package:digimap_pandonga/core/config/const.dart';
import 'package:digimap_pandonga/pages/splash_page.dart';

// Ext
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: fontFamilyIdentifier,
      ),
      home: MessageHandler(),
    );
  }
}

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  void _configFCM() {
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showNotification(message: message['notification']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  void _configLocalNotif() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _localNotification.initialize(initializationSettings);
  }

  void _showNotification({Map message}) async {
    DateTime now = DateTime.now();

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'com.example.sindu_new',
      'Digital Mapping',
      'Lorem ipsum dolor sit amet.',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await _localNotification.show(
      now.hour + now.minute + now.second,
      message['title'].toString(),
      message['body'].toString(),
      platformChannelSpecifics,
    );
  }

  @override
  void initState() {
    super.initState();
    _configFCM();
    _configLocalNotif();
  }

  @override
  Widget build(BuildContext context) {
    return SplashPage();
  }
}
