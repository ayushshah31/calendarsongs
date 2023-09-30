// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:calendarsong/auth/auth.dart';
// import 'package:calendarsong/constants/routes.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();

//   bool _obscureText = true;
//   String email = "";
//   String pass = "";

//   void changeObscure() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login'),automaticallyImplyLeading: false),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             TextFormField(
//               decoration: const InputDecoration(
//                 prefixIcon: Icon(
//                     Icons.person_outline_rounded),
//                 border: OutlineInputBorder(
//                   borderSide:
//                   BorderSide(color: Colors.white),
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(8),
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide:
//                   BorderSide(color: Colors.white),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide:
//                   BorderSide(color: Colors.white),
//                 ),
//                 hintText: 'Email',
//                 filled: true,
//               ),
//               keyboardType: TextInputType.emailAddress,
//               validator: (val) => val!.isEmpty? 'Enter an Email' : null,
//               onChanged: (val){
//                 setState(() {
//                   email = val;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.lock_outline),
//                 suffixIcon: GestureDetector(
//                   onTap: changeObscure,
//                   child: Icon(_obscureText
//                       ? Icons.remove_red_eye_outlined
//                       : Icons
//                       .visibility_off_outlined),
//                 ),
//                 border: const OutlineInputBorder(
//                   borderSide:
//                   BorderSide(color: Colors.white),
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(8),
//                   ),
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide:
//                   BorderSide(color: Colors.white),
//                 ),
//                 enabledBorder: const OutlineInputBorder(
//                   borderSide:
//                   BorderSide(color: Colors.white),
//                 ),
//                 hintText: 'Password',
//                 filled: true,
//               ),
//               obscureText: _obscureText,
//               validator: (val) => val!.length<6? 'Password minimum 6 chars' : null,
//               onChanged: (val){
//                 setState(() {
//                   pass = val;
//                 });
//               },
//             ),
//             TextButton(
//                 onPressed: () async{
//                   if(_formKey.currentState!.validate()) {
//                     dynamic result = await _auth.signInEmailPassword(email, pass);
//                     print("res: $result");
//                     if(result.toString().contains("user-not-found")){
//                       const snackBar = SnackBar(
//                         content: Text('Incorrect email or password'),
//                         duration: Duration(seconds: 3),
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     } else if(result.toString().contains("wrong-password")){
//                       const snackBar = SnackBar(
//                         content: Text('Incorrect email or password'),
//                         duration: Duration(seconds: 3),
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                     } else{
//                       Navigator.pushNamed(context, wrapperRoute);
//                     }

//                   }
//                 },
//                 child: const Text("Submit")
//             ),
//             const SizedBox(height: 10),
//             const Text("Or Using Google: "),
//             IconButton(onPressed: () async{
//                 final result = await _auth.handleSignIn();
//                 print("res: $result");
//             }, icon: const Icon(Icons.g_mobiledata)),
//             const SizedBox(height:20),
//             TextButton(onPressed: ()=>Navigator.of(context).pushNamed(signupRoute), child: const Text("New User? Sign Up here"))
//           ],
//         ),
//       ),
//     );
//   }
// }
