import 'package:daily_doii/utils/NotificationsService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Calendarios/Pagina Principal.dart';
import 'Init/Login.dart';
import 'l10n/l10n.dart';
import 'services/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();
  var initialNotification =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {
    Future.delayed(Duration(seconds: 1), () {
      // print(event);
      navigatorKey.currentState!.pushNamed('/another',
          arguments: initialNotification?.notificationResponse?.payload);
    });
  }
  tz.initializeTimeZones();



  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var loggedInUser = prefs.getString('loggedInUser');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(loggedInUser: loggedInUser));
}

class MyApp extends StatefulWidget {
  final String? loggedInUser;

  const MyApp({Key? key, this.loggedInUser}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? keepLoggedIn;

  @override
  void initState() {
    super.initState();
    _loadKeepLoggedIn();
  }

  void _loadKeepLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Add this line
      supportedLocales: L10n.all,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      locale: Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'DailyDo',
      home: keepLoggedIn ?? false ? MainPage() : LoginScreen(),
    );
  }
}
