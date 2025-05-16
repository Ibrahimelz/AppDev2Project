import 'package:appdev2/splash.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:appdev2/services/notification_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: FirebaseOptions(
       apiKey: "AIzaSyCbyqHn4yXwCwUtayJdHuCRiM2SWiZ2Tyo",
       appId: "147369913623",
       messagingSenderId: "147369913623",
       projectId: "titanfitness-a55fd"
   )
  );
  
  // Initialize notification service
  await NotificationService().initialize();

  // Check for initial notification action
  final initialAction = await AwesomeNotifications().getInitialNotificationAction();
  final openNotificationsPage = initialAction != null;

  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(openNotificationsPage: openNotificationsPage));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.openNotificationsPage = false});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final bool openNotificationsPage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
     navigatorKey: navigatorKey,
     home: splashScreen(openNotificationsPage: openNotificationsPage),
    );
  }
}
