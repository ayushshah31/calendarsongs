import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calendarsong/auth/auth.dart';
import 'package:flutter/services.dart';

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
  String name = "";
  int phoneNo = 0;

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
      appBar: AppBar(title: const Text('Register'),automaticallyImplyLeading: false,centerTitle: true,),
      backgroundColor: const Color(0xfff8dbc1),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset('lib/assets/images/image.png',),
                    ),
                  ),
              ),
              const Text(
                "Mantra Therapy",
                style: TextStyle(
                  fontSize: 40,
                  color: Color(0xff992e1e)
                ),),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                                Icons.mail),
                            border: const OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20)
                            ),
                            hintText: 'Email',
                            filled: true,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val!.contains("@") && val.contains(".") ? null: "Enter a Valid email",
                          onChanged: (val){
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                                Icons.person),
                            border: const OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20)
                            ),
                            hintText: 'Name',
                            filled: true,
                          ),
                          validator: (val)=>val==""?"Enter a valid name":null,
                          onChanged: (val){
                            name = val;
                          }
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                                Icons.call),
                            border: const OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20)
                            ),
                            hintText: 'Phone',
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val)=>val!.length<10?"Enter a valid phone":null,
                          onChanged: (val){
                            phoneNo = int.parse(val.toString());
                          },
                        ),

                    // TextFormField(
                        //   decoration: InputDecoration(
                        //     prefixIcon: const Icon(Icons.lock_outline),
                        //     suffixIcon: GestureDetector(
                        //       onTap: changeObscure,
                        //       child: Icon(_obscureText
                        //           ? Icons.remove_red_eye_outlined
                        //           : Icons
                        //           .visibility_off_outlined),
                        //     ),
                        //     border: const OutlineInputBorder(
                        //       borderSide:
                        //       BorderSide(color: Colors.white),
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(8),
                        //       ),
                        //     ),
                        //     focusedBorder: const OutlineInputBorder(
                        //       borderSide:
                        //       BorderSide(color: Colors.white),
                        //     ),
                        //     enabledBorder: const OutlineInputBorder(
                        //       borderSide:
                        //       BorderSide(color: Colors.white),
                        //     ),
                        //     hintText: 'Password',
                        //     filled: true,
                        //   ),
                        //   obscureText: _obscureText,
                        //   validator: (value) {
                        //     if (value!.length < 8) {
                        //       return 'Password must be at least 8 characters long';
                        //     }
                        //     return null;
                        //   },
                        //   onChanged: (val){
                        //     setState(() {
                        //       pass = val;
                        //     });
                        //   },
                        // ),
                        // TextFormField(
                        //   decoration: InputDecoration(
                        //     prefixIcon: const Icon(Icons.lock_outline),
                        //     suffixIcon: GestureDetector(
                        //       onTap: changeObscure2,
                        //       child: Icon(_obscureText2
                        //           ? Icons.remove_red_eye_outlined
                        //           : Icons.visibility_off_outlined),
                        //     ),
                        //     helperText: '',
                        //     contentPadding: const EdgeInsets.symmetric(
                        //       vertical: 0.0,
                        //       horizontal: 10.0,
                        //     ),
                        //     border: const OutlineInputBorder(
                        //       borderSide:
                        //       BorderSide(color: Colors.white),
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(8),
                        //       ),
                        //     ),
                        //     focusedBorder: const OutlineInputBorder(
                        //       borderSide:
                        //       BorderSide(color: Colors.white),
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(8),
                        //       ),
                        //     ),
                        //     enabledBorder: const OutlineInputBorder(
                        //       borderSide:
                        //       BorderSide(color: Colors.white),
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(8),
                        //       ),
                        //     ),
                        //     hintText: 'At least 8 characters long',
                        //     filled: true,
                        //   ),
                        //   obscureText: _obscureText2,
                        //   validator: (val) => val!=pass? 'Passwords don\'t match' : null,
                        //   onChanged: (val){},
                        // ),
                        OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                foregroundColor: MaterialStateProperty.all(Colors.white)
                            ),
                            onPressed: () async{
                              if(_formKey.currentState!.validate()) {
                                final result = await _auth.signUpEmailPassword(email, "pass@1234");
                                print(result);
                                if(result.toString().contains("email-already-in-use")){
                                  const snackBar = SnackBar(
                                    content: Text('Email already in use'),
                                    duration: Duration(seconds: 3),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } else {
                                  print(FirebaseAuth.instance.currentUser);
                                  Navigator.pushNamed(context, wrapperRoute);
                                }
                              }
                            },
                            child: const Text("Register")
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
