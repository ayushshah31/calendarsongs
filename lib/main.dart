import 'package:calendarsong/Screens/feedback.dart';
import 'package:calendarsong/Screens/wrapper.dart';
import 'package:calendarsong/constants/common.dart';
import 'package:calendarsong/model/mantraData.dart';
// import 'package:calendarsong/model/mantraData.dart';
import 'package:calendarsong/providers/userRepeatData.dart';
import 'package:calendarsong/services/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/home.dart';
import 'constants/routes.dart';
import 'providers/mantraDataProvider.dart';
import 'providers/tithiDataProvider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await checkPermission();
  // await initAudioService();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MantraViewModel()),
        ChangeNotifierProvider(create: (_) => TithiViewModel()),
        ChangeNotifierProvider(create: (_) => UserRepeatViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    checkPermission();
    List<MantraModel> mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    dynamic tithiData = Provider.of<TithiViewModel>(context).tithiModel;
    print("In main $mantraData");
    print("In main $tithiData");
    return MaterialApp(
      // builder: (context,child){
      //   return MantraPlay();
      // },
      navigatorObservers: <NavigatorObserver>[observer],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffF4B651),
          // background: Color(0xfff8dbc1)
        ),
        appBarTheme: AppBarTheme(color: const Color(0xFFf3ae85)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFFf3ae85),
        ),
        splashColor: Color(0xffFFC680),
        buttonTheme: ButtonThemeData(buttonColor: Color(0xffd1542e)),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.orangeAccent,
          shadowColor: Colors.black12,
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)), child: child!);
      },
      debugShowCheckedModeBanner: false,
      initialRoute: wrapperRoute,
      routes: {
        wrapperRoute: (context) => Wrapper(analytics: analytics, observer: observer),
        feedback: (context) => const FeedbackPage(),
        home: (context) => HomePage(),
      },
    );
  }
}
