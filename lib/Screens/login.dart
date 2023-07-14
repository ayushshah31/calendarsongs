import 'package:flutter/material.dart';
import 'package:calendarsong/auth/auth.dart';
import 'package:calendarsong/constants/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String pass = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),automaticallyImplyLeading: false),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter Email'),
              validator: (val) => val!.isEmpty? 'Enter an Email' : null,
              onChanged: (val){
                setState(() {
                  email = val;
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter Password'),
              obscureText: true,
              validator: (val) => val!.length<6? 'Password minimum 6 chars' : null,
              onChanged: (val){
                setState(() {
                  pass = val;
                });
              },
            ),
            TextButton(
                onPressed: () async{
                  if(_formKey.currentState!.validate()) {
                    final result = await _auth.signInEmailPassword(email, pass);
                    print("res: $result");
                    if(result.toString().contains("user-not-found")){
                      const snackBar = SnackBar(
                        content: Text('Incorrect email or password'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else if(result.toString().contains("wrong-password")){
                      const snackBar = SnackBar(
                        content: Text('Incorrect email or password'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                  }
                },
                child: const Text("Submit")
            ),
            const SizedBox(height: 10),
            const Text("Or Using Google: "),
            IconButton(onPressed: (){
                final result = _auth.handleSignIn();
                print("res: $result");
            }, icon: const Icon(Icons.g_mobiledata)),
            const SizedBox(height:20),
            TextButton(onPressed: ()=>Navigator.of(context).pushNamed(signupRoute), child: const Text("New User? Sign Up here"))
          ],
        ),
      ),
    );
  }
}
