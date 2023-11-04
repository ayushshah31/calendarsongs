import 'package:calendarsong/data/FirebaseFetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

enum RadioVal { Yes, No, NotSelected }

class _FeedbackPageState extends State<FeedbackPage> {
  String body = "";
  String email = "", name = "", phone = "";
  final _key = GlobalKey<FormState>();
  TextEditingController bodyController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  RadioVal radioVal = RadioVal.NotSelected;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mantra Therapy"),
          centerTitle: true,
        ),
        backgroundColor: const Color(0xfff8dbc1),
        body: SingleChildScrollView(
          child: Container(
            // height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Feel free to give suggestions to enhance this app or any issues you are facing.",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.023),
                ),
                SizedBox(height: 10),
                Text(
                  "If you wish to be contacted then you can enter your name, email or phone",
                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.023),
                ),
                SizedBox(height: 10),
                Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(
                      //   padding: EdgeInsets.all(10),
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(color: Colors.black)),
                      //   child: TextFormField(
                      //     controller: emailController,
                      //     decoration: InputDecoration(
                      //         labelText: "Email(Optional)",
                      //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      //         hintText: "abc@gmail.com",
                      //         disabledBorder: InputBorder.none,
                      //         enabledBorder: InputBorder.none,
                      //         focusedBorder: InputBorder.none,
                      //         contentPadding: const EdgeInsets.only(left: 10),
                      //         hintStyle: const TextStyle(fontSize: 16)),
                      //     textInputAction: TextInputAction.done,
                      //     style: const TextStyle(fontSize: 14),
                      //     onChanged: (value) {
                      //       email = value;
                      //     },
                      //     validator: (value) => value.toString().trim() != ""
                      //         ? ((value!.contains("@") &&
                      //                 value.substring(value.indexOf("@")).contains("."))
                      //             ? null
                      //             : "Enter proper email")
                      //         : null,
                      //   ),
                      // ),
                      // Spacer(),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black)),
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              labelText: "Name(Optional)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              hintText: "Jon Doe",
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 10),
                              hintStyle: const TextStyle(fontSize: 16)),
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(fontSize: 14),
                          onChanged: (value) {
                            name = value;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        // padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black)),
                        child: IntlPhoneField(
                          controller: phoneController,
                          disableLengthCheck: true,
                          decoration: InputDecoration(
                              labelText: 'Phone Number(Optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintText: "1234567890",
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              // contentPadding: EdgeInsets.only(left: 10),
                              hintStyle: const TextStyle(fontSize: 16)),
                          initialCountryCode: 'IN',
                          onChanged: (mob) {
                            print(mob.completeNumber);
                            phone = mob.completeNumber;
                          },
                          validator: null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "I wish to volunteer to promote/enhacne/test this App",
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022),
                      ),
                      Row(
                        children: [
                          Radio(
                              value: RadioVal.Yes,
                              groupValue: radioVal,
                              onChanged: (val) {
                                print(val);
                                setState(() {
                                  radioVal = RadioVal.Yes;
                                });
                              }),
                          Text(
                            "Yes",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022),
                          ),
                          Radio(
                              value: RadioVal.No,
                              groupValue: radioVal,
                              onChanged: (val) {
                                setState(() {
                                  radioVal = RadioVal.No;
                                });
                              }),
                          Text(
                            "No",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.022),
                          ),
                        ],
                      ),
                      errorMsg == ""
                          ? Container()
                          : Text(errorMsg,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: MediaQuery.of(context).size.height * 0.018,
                              )),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black)),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 10),
                        child: TextFormField(
                          controller: bodyController,
                          // minLines: (height * 0.012).toInt(),
                          maxLines: 6,
                          decoration: InputDecoration(
                              labelText: "Your Feedback",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              hintText: "Enter Feedback here",
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 10),
                              hintStyle: const TextStyle(fontSize: 16)),
                          keyboardType: TextInputType.text,
                          // textInputAction: TextInputAction.done,
                          style: const TextStyle(fontSize: 16),
                          autocorrect: true,
                          onChanged: (value) {
                            print(value);
                            body = value;
                          },
                          validator: (val) =>
                              val.toString().trim() == "" ? "Feedback cannot be empty" : null,
                        ),
                      ),
                      // Spacer(),
                      SizedBox(height: 10),
                      OutlinedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent),
                              foregroundColor: MaterialStateProperty.all(Colors.white)),
                          onPressed: () async {
                            if (radioVal == RadioVal.NotSelected) {
                              setState(() {
                                errorMsg = "Please select an option";
                              });
                              return;
                            }
                            if (_key.currentState!.validate()) {
                              print("Val");
                              // print(subj);
                              print(body);
                              final ff = FirebaseFetch();
                              var res = await ff.saveFeedback(
                                  body, name, phone, radioVal == RadioVal.Yes ? "Yes" : "No");
                              print(radioVal.name);
                              print(res);
                              print(DateTime.now());
                              if (res) {
                                const snackBar = SnackBar(
                                  content: Text(
                                    'Thank You! Your Feedback has been saved',
                                    style: TextStyle(color: Colors.white, fontSize: 22),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  backgroundColor: Color(0xff80571d),
                                  duration: Duration(seconds: 3),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } else {
                                const snackBar = SnackBar(
                                  content: Text('An error occured'),
                                  duration: Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                              setState(() {
                                bodyController.text = "";
                                emailController.text = "";
                                nameController.text = "";
                                phoneController.text = "";
                                radioVal = RadioVal.NotSelected;
                                errorMsg = "";
                                name = "";
                                phone = "";
                                body = "";
                              });
                              // Future.delayed(const Duration(seconds: 2),(){
                              //   Navigator.of(context).pop();
                              // });
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
                          child: Text("Send")),
                    ],
                  ),
                ),
                // Spacer(
                //   flex: 5,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
