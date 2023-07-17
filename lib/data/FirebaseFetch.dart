import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class FirebaseFetch{

  final firebaseDatabase = FirebaseDatabase.instance.ref();

  Future<List> getMantra() async {
    var result = (await firebaseDatabase.child("mantra").once()).snapshot.value as List;
    List mantra = [];
    for (LinkedHashMap child in result) {
      // print(child);
      mantra.add(child);
    }
    print("Mantra: $mantra");
    return mantra;
  }
  Future<List> getMantraData() async {
    var result = (await firebaseDatabase.child("mantraData").once()).snapshot.value as List;
    List mantraData = [];
    for (LinkedHashMap child in result) {
      // print(child);
      mantraData.add(child);
    }
    print("MantraData: $mantraData");
    return mantraData;
  }

  Future<dynamic> getTithiData() async {
    var result = (await firebaseDatabase.child("dateToTithi").once()).snapshot.value;
    dynamic tithi;
    // for (LinkedHashMap child in result) {
    //   // print(child);
    //   tithi.add(child);
    // }
    print("Tithi: $result");
    return result;
  }

  Future<void> saveFeedback(String body, String subject,User user) async{
    await firebaseDatabase.child("feedbacks").child(user.uid).child("body").set(body);
    await firebaseDatabase.child("feedbacks").child(user.uid).child("subject").set(subject);
  }

}