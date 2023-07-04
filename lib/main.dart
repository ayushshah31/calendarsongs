import 'package:calendarsong/Screens/customCalendar.dart';
import 'package:calendarsong/Screens/home.dart';
import 'package:calendarsong/Screens/signUp.dart';
import 'package:calendarsong/Screens/wrapper.dart';
import 'package:calendarsong/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/routes.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        // useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: customCalendar,
      routes: {
        wrapperRoute: (context) => const Wrapper(),
        signupRoute: (context) => const SignUp(),
        homeScreenRoute: (context) => TableComplexExample(),
        customCalendar: (context) => const CustomCalendar()
      },
    );
  }
}
