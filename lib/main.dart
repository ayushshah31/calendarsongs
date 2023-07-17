import 'package:audio_service/audio_service.dart';
import 'package:calendarsong/Screens/customCalendar.dart';
import 'package:calendarsong/Screens/feedback.dart';
import 'package:calendarsong/Screens/playlists.dart';
import 'package:calendarsong/Screens/login.dart';
import 'package:calendarsong/Screens/signUp.dart';
import 'package:calendarsong/Screens/wrapper.dart';
import 'package:calendarsong/auth/auth.dart';
import 'package:calendarsong/constants/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Widgets/audioPlayerHandler.dart';
import 'constants/routes.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // _audioHandler = await AudioService.init(
  //   builder: () => AudioPlayerHandler(),
  //   config: const AudioServiceConfig(
  //     androidNotificationChannelId: 'com.example.tithiapp',
  //     androidNotificationChannelName: 'Audio playback',
  //     androidNotificationOngoing: true,
  //   ),
  // );
  runApp(StreamProvider<User?>.value(
    value: AuthService().user,
    initialData: FirebaseAuth.instance.currentUser,
    builder: (context, snapshot) {
      return const MyApp();
    }
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    checkPermission();
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffF4B651),
            background: Color(0xfff8dbc1)
        ),
        appBarTheme: AppBarTheme(color: const Color(0xFFf3ae85)),
        splashColor: Color(0xffFFC680),
        buttonTheme: ButtonThemeData(buttonColor: Color(0xffd1542e)),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.orangeAccent,
          shadowColor: Colors.black12,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: wrapperRoute,
      routes: {
        wrapperRoute: (context) => const Wrapper(),
        signupRoute: (context) => const SignUp(),
        playlists: (context) => const Playlists(),
        customCalendar: (context) => const CustomCalendar(),
        loginRoute: (contect) => const LoginPage(),
        feedback: (context) => const FeedbackPage()
      },
    );
  }
}
