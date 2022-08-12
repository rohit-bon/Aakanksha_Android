import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:humanly/COMPONENTS/Constants.dart';
import 'package:humanly/PAGES/ADMIN/AdminHome.dart';
import 'package:humanly/PAGES/ADMIN/Leaderboard.dart';
import 'package:humanly/PAGES/ADMIN/Members.dart';
import 'package:humanly/PAGES/ADMIN/SosAlerts.dart';
import 'package:humanly/PAGES/ADMIN/Sponser.dart';
import 'package:humanly/PAGES/ProfileScreen.dart';
import 'package:humanly/PAGES/SignUpScreen.dart';
import 'package:humanly/PAGES/SosSenderScreen.dart';
import 'package:humanly/PAGES/UserReviews.dart';
import 'package:humanly/PAGES/UserScreen.dart';
import 'package:humanly/PAGES/UserSponser.dart';
import 'package:humanly/PAGES/searchmember.dart';
import 'package:humanly/notificationservice.dart';
import 'package:workmanager/workmanager.dart';
import 'package:humanly/MODELS/GuestModel.dart';
import 'package:humanly/MODELS/UserLocationModel.dart';
import 'package:humanly/PAGES/GuestHome.dart';
import 'package:humanly/PAGES/SplashScreen.dart';
import 'package:humanly/SERVICES/LocationService.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await FirebaseMessaging.instance.subscribeToTopic('myTopic');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocationModel>(
        create: (context) => LocationService().locationStream,
        child: MaterialApp(
          title: 'Aakanksha',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.grey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/signup': (context) => SignUp(),
            '/guest': (context) => Guest(),
            '/sender': (context) => SosSenderScreen(),
            '/user': (context) => User(),
            '/profile': (context) => ProfileScreen(),
            '/admin': (context) => AdminHome(),
            '/members': (context) => Members(),
            '/sosStats': (context) => SosAlerts(),
            '/sponsers': (context) => Sponser(),
            '/sponser': (context) => UserSponser(),
            '/leaderboard': (context) => Leaderboard(),
            '/myReview': (context) => UserReview(),
            '/searchmem': (context) => searchMember(),
          },
        ));
  }
}
