import 'package:calendarsong/data/FirebaseFetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../constants/routes.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {

  String subj = "" ;
  String body = "" ;
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      backgroundColor: const Color(0xfff8dbc1),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "User: ${FirebaseAuth.instance.currentUser!.email}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Text("Enter your feedback below: ",style: TextStyle(fontSize: 16),),
                const SizedBox(height: 20),
                Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Enter Subject:"),
                      const SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.black
                            )
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              hintText: "Please write ",
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.only(left:10, top: 20),
                              hintStyle: const TextStyle(fontSize: 16)
                          ),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(fontSize: 16),
                          autocorrect: true,
                          maxLines: 2,
                          onChanged: (value){
                            subj = value;
                          },
                          validator: (val)=>val.toString().trim()==""? "Cannot be empty": null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Enter Body"),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black
                          )
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          // minLines: (height * 0.012).toInt(),
                          maxLines: 10,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              hintText: "Please write ",
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                              const EdgeInsets.only(left:10, top: 20),
                              hintStyle: const TextStyle(fontSize: 16)
                          ),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(fontSize: 16),
                          autocorrect: true,
                          onChanged: (value) {
                            print(value);
                            body = value;
                          },
                          validator: (val)=> val.toString().trim()==""?"Body cannot be empty":null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                              foregroundColor: MaterialStateProperty.all(Colors.white)
                          ),
                          onPressed: () async{
                            if(_key.currentState!.validate()){
                              print("Val");
                              print(subj);
                              print(body);
                              final ff = FirebaseFetch();
                              var res = await ff.saveFeedback(body, subj, FirebaseAuth.instance.currentUser!);
                              if(res){
                                const snackBar = SnackBar(
                                  content: Text('Feedback Saved'),
                                  duration: Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } else {
                                const snackBar = SnackBar(
                                  content: Text('An error occured'),
                                  duration: Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                              Future.delayed(const Duration(seconds: 2),(){
                                Navigator.of(context).pushNamed(home);
                              });
                              // final Email email = Email(
                              //   body: body,
                              //   subject: subj,
                              //   recipients: ['shahayush934@gmail.com'],
                              //   isHTML: false,
                              // );
                              //
                              // await FlutterEmailSender.send(email);
                            }
                          },
                          child: Text("Send")
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
