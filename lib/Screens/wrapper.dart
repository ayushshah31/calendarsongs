import 'package:calendarsong/Screens/customCalendar.dart';
import 'package:calendarsong/Screens/login.dart';
import 'package:calendarsong/Screens/playlists.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if(user == null) {
      return const LoginPage();
    }
    return const CustomCalendar();
  }
}
