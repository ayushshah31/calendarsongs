import 'package:calendarsong/Screens/customCalendar.dart';
import 'package:calendarsong/Screens/feedback.dart';
import 'package:calendarsong/Screens/playlists.dart';
import 'package:calendarsong/Screens/login.dart';
import 'package:calendarsong/Screens/signUp.dart';
import 'package:calendarsong/Screens/wrapper.dart';
import 'package:calendarsong/auth/auth.dart';
import 'package:calendarsong/constants/common.dart';
import 'package:calendarsong/model/mantraData.dart';
import 'package:calendarsong/services/audio_handler.dart';
import 'package:calendarsong/services/playlist_repository.dart';
import 'package:calendarsong/services/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/home.dart';
import 'constants/routes.dart';
import 'providers/mantraDataProvider.dart';
import 'providers/tithiDataProvider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await checkPermission();
  // await initAudioService();
  await setupServiceLocator();
  runApp(StreamProvider<User?>.value(
    value: AuthService().user,
    initialData: FirebaseAuth.instance.currentUser,
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MantraViewModel()),
        ChangeNotifierProvider(create: (_) => TithiViewModel()),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    checkPermission();
    List<MantraModel> mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    dynamic tithiData = Provider.of<TithiViewModel>(context).tithiModel;
    // print("In main $mantraData");
    return MaterialApp(
      // builder: (context,child){
      //   return MantraPlay();
      // },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffF4B651),
            // background: Color(0xfff8dbc1)
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
        wrapperRoute: (context) => Wrapper(),
        signupRoute: (context) => const SignUp(),
        playlists: (context) => const Playlists(),
        // customCalendar: (context) => CustomCalendar(),
        loginRoute: (contect) => const LoginPage(),
        feedback: (context) => const FeedbackPage(),
        home: (context)=> const HomePage(),
      },
    );
  }
}
