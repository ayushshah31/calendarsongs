import 'package:firebase_auth/firebase_auth.dart';
import './signUp.dart';
import 'package:calendarsong/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final _auth = AuthService();
    if(user == null) {
      return const SignUp();
    }
    return Scaffold(body: Column(
      children: [
        TextButton(
          onPressed: (){
            _auth.handleSignOut();
          },
            child: const Text("SignOut")
        )
      ]
    ),);
  }
}
