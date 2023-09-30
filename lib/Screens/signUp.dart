// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:calendarsong/auth/auth.dart';
// import 'package:flutter/services.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// import '../constants/routes.dart';

// class SignUp extends StatefulWidget {
//   const SignUp({Key? key}) : super(key: key);

//   @override
//   State<SignUp> createState() => _SignUpState();
// }

// class _SignUpState extends State<SignUp> {
//   final _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();
//   bool _obscureText = true;
//   bool _obscureText2 = true;
//   String email = "";
//   String name = "";
//   String phoneNo = "";
//   DatabaseReference _database = FirebaseDatabase.instance.ref();

//   void changeObscure() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }

//   void changeObscure2() {
//     setState(() {
//       _obscureText2 = !_obscureText2;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register'),automaticallyImplyLeading: false,centerTitle: true,),
//       backgroundColor: const Color(0xfff8dbc1),
//       body: SingleChildScrollView(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           child: Column(
//             children: [
//               Expanded(
//                 flex: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Hero(
//                       tag: 'logo',
//                       child: Image.asset('lib/assets/images/image.png',),
//                     ),
//                   ),
//               ),
//               const Text(
//                 "Mantra Therapy",
//                 style: TextStyle(
//                   fontSize: 40,
//                   color: Color(0xff992e1e)
//                 ),),
//               Expanded(
//                 flex: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 10),
//                         TextFormField(
//                           decoration: InputDecoration(
//                             labelText: "Email",
//                             prefixIcon: const Icon(
//                                 Icons.mail),
//                             border: const OutlineInputBorder(
//                               borderSide:
//                               BorderSide(color: Colors.white),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(20),
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide:
//                               const BorderSide(color: Colors.white),
//                               borderRadius: BorderRadius.circular(20)
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide:
//                               const BorderSide(color: Colors.white),
//                                 borderRadius: BorderRadius.circular(20)
//                             ),
//                             hintText: 'Email',
//                             filled: true,
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (val) => val!.contains("@") && val.contains(".") ? null: "Enter a Valid email",
//                           onChanged: (val){
//                             setState(() {
//                               email = val;
//                             });
//                           },
//                         ),
//                         const SizedBox(height: 10),
//                         TextFormField(
//                           decoration: InputDecoration(
//                             labelText: "Name",
//                             prefixIcon: const Icon(
//                                 Icons.person),
//                             border: const OutlineInputBorder(
//                               borderSide:
//                               BorderSide(color: Colors.white),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(20),
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide:
//                               const BorderSide(color: Colors.white),
//                                 borderRadius: BorderRadius.circular(20)
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide:
//                               const BorderSide(color: Colors.white),
//                                 borderRadius: BorderRadius.circular(20)
//                             ),
//                             hintText: 'Name',
//                             filled: true,
//                           ),
//                           validator: (val)=>val==""?"Enter a valid name":null,
//                           onChanged: (val){
//                             name = val;
//                           }
//                         ),
//                         const SizedBox(height: 10),
//                         // TextFormField(
//                         //   decoration: InputDecoration(
//                         //     prefixIcon: const Icon(
//                         //         Icons.call),
//                         //     border: const OutlineInputBorder(
//                         //       borderSide:
//                         //       BorderSide(color: Colors.white),
//                         //       borderRadius: BorderRadius.all(
//                         //         Radius.circular(20),
//                         //       ),
//                         //     ),
//                         //     focusedBorder: OutlineInputBorder(
//                         //       borderSide: const BorderSide(color: Colors.white),
//                         //         borderRadius: BorderRadius.circular(20)
//                         //     ),
//                         //     enabledBorder: OutlineInputBorder(
//                         //       borderSide: const BorderSide(color: Colors.white),
//                         //         borderRadius: BorderRadius.circular(20)
//                         //     ),
//                         //     hintText: 'Phone',
//                         //     filled: true,
//                         //   ),
//                         //   inputFormatters: [
//                         //     FilteringTextInputFormatter
//                         //         .digitsOnly,
//                         //     LengthLimitingTextInputFormatter(
//                         //         10)
//                         //   ],
//                         //   keyboardType: TextInputType.number,
//                         //   validator: (val)=>val!.length<10?"Enter a valid phone":null,
//                         //   onChanged: (val){
//                         //     phoneNo = int.parse(val.toString());
//                         //   },
//                         // ),
//                         // const SizedBox(height: 10),
//                         IntlPhoneField(
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(
//                                 Icons.call),
//                             border: const OutlineInputBorder(
//                               borderSide:
//                               BorderSide(color: Colors.white),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(20),
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(color: Colors.white),
//                                 borderRadius: BorderRadius.circular(20)
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                                 borderSide: const BorderSide(color: Colors.white),
//                                 borderRadius: BorderRadius.circular(20)
//                             ),
//                             hintText: 'Phone',
//                             filled: true,
//                           ),
//                           initialCountryCode: 'IN',
//                           onChanged: (phone) {
//                             print(phone.completeNumber);
//                             phoneNo = phone.completeNumber;
//                           },
//                         ),
//                         OutlinedButton(
//                             style: ButtonStyle(
//                                 backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
//                                 foregroundColor: MaterialStateProperty.all(Colors.white)
//                             ),
//                             onPressed: () async{
//                               if(_formKey.currentState!.validate()) {
//                                 User? result = await _auth.signUpEmailPassword(email, "pass@1234");
//                                 // print(result);
//                                 if(result == null){
//                                   User? res2 = await _auth.signInEmailPassword(email, "pass@1234");
//                                   print(res2);
//                                   if(res2 != null){
//                                     var dataFound = (await _database
//                                         .child("users")
//                                         .child(res2.uid)
//                                         .once())
//                                         .snapshot
//                                         .value;
//                                     print("datafound: $dataFound");
//                                   } else{
//                                     print("Error occurred");
//                                   }
//                                 } else {
//                                   print(FirebaseAuth.instance.currentUser);
//                                   await _database.child("users").child(result.uid).child("email").set(email);
//                                   await _database.child("users").child(result.uid).child("name").set(name);
//                                   await _database.child("users").child(result.uid).child("phone").set(phoneNo);
//                                   Navigator.pushNamed(context, wrapperRoute);
//                                 }
//                               }
//                             },
//                             child: const Text("Register")
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
