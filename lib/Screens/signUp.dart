import 'package:flutter/material.dart';
import 'package:calendarsong/auth/auth.dart';

import '../constants/routes.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureText2 = true;
  String email = "";
  String pass = "";

  void changeObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void changeObscure2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SignUp'),automaticallyImplyLeading: false,),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                      Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                  ),
                  hintText: 'Email',
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty? 'Enter an Email' : null,
                onChanged: (val){
                  setState(() {
                    email = val;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    child: Icon(_obscureText
                        ? Icons.remove_red_eye_outlined
                        : Icons
                        .visibility_off_outlined),
                    onTap: changeObscure,
                  ),
                  border: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                  ),
                  hintText: 'Password',
                  filled: true,
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value!.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
                onChanged: (val){
                  setState(() {
                    pass = val;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: GestureDetector(
                    child: Icon(_obscureText2
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off_outlined),
                    onTap: changeObscure2,
                  ),
                  helperText: '',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 10.0,
                  ),
                  border: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  hintText: 'At least 8 characters long',
                  filled: true,
                ),
                obscureText: _obscureText2,
                validator: (val) => val!=pass? 'Passwords don\'t match' : null,
                onChanged: (val){},
              ),
              TextButton(
                  onPressed: () async{
                    if(_formKey.currentState!.validate()) {
                      final result = await _auth.signUpEmailPassword(email, pass);
                      print(result);
                    }
                  },
                  child: const Text("Submit")
              ),
              const SizedBox(height: 10),
              const Text("Or Using Google: "),
              IconButton(onPressed: (){
                final result = _auth.handleSignIn();
                print(result);
              }, icon: const Icon(Icons.g_mobiledata)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: ()=> Navigator.of(context).pushNamed(loginRoute),
                child: Text("Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
