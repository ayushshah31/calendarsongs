import 'dart:collection';
import 'package:calendarsong/model/mantraData.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseFetch {
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

  Future fetchShareMsg() async {
    dynamic res = (await firebaseDatabase.child("share").once()).snapshot.value;
    print("Share data: $res");
    return res;
  }

  Future<List> getMantraData() async {
    var result = (await firebaseDatabase.child("mantraData").once()).snapshot.value as List;
    List mantraData = [];
    for (LinkedHashMap child in result) {
      // print(child);
      // MantraModel _mantra = new MantraModel();
      // _mantra.mantraSoundFile = child["Mantra Sound file"];
      // _mantra.tithi = child["Tithi"]
      mantraData.add(child);
    }
    print("MantraData: $mantraData");
    return mantraData;
  }

  Future<List<MantraModel>> getMantraDataPro() async {
    var result = (await firebaseDatabase.child("mantraData").once()).snapshot.value as List;
    List<MantraModel> mantraData = [];
    for (LinkedHashMap child in result) {
      // print(child);
      MantraModel mantra = MantraModel();
      mantra
        ..noOfRep = child["Number of Repetitions"]
        ..introLink = child["introLink"]
        ..introSoundFile = child["Intro Sound File"]
        ..benefits = child["Benefit"]
        ..tithi = child["Tithi"]
        ..mantraSoundFile = child["Mantra Sound file"]
        ..mantraLink = child["mantraLink"]
        ..mantraEnglish = child["Mantra English"]
        ..mantraHindi = child["Mantra Hindi"]
        ..procedure = child["Procedure"];
      mantraData.add(mantra);
    }
    // print("MantraData: $mantraData");
    return mantraData;
  }

  Future<dynamic> getTithiData() async {
    var result = (await firebaseDatabase.child("dateToTithi").once()).snapshot.value;
    // for (LinkedHashMap child in result) {
    //   // print(child);
    //   tithi.add(child);
    // }
    // print("Tithi: $result");
    return result;
  }

  // Future getTithiDataPro() async{
  //   var result = (await firebaseDatabase.child("dateToTithi").once()).snapshot.value;
  //   List<TithiModel> tithi;
  //   for(LinkedHashMap child in result){
  //     TithiModel _ = TithiModel();
  //     print("Tithi loop values: ${child.values}");
  //     _.tithi = child.values.first;
  //     _.date = child.keys.first;
  //   }
  // }

  Future<bool> saveFeedback(String body, String name, String phone, String vol) async {
    try {
      // final dataFound = (await firebaseDatabase.child("feedbacks").once()).snapshot.value;
      // print(dataFound);
      // if(dataFound == null){
      //   print("No data");
      //   await firebaseDatabase.child("feedbacks").child(user.uid)
      //       .set();
      // }
      final newData = {
        // "email": email,
        "name": name,
        "phone": phone,
        "volunteer": vol,
        "body": body,
        "time": DateTime.now().toString()
      };
      firebaseDatabase.child("userFeedbacks").push().set(newData);
      return true;
    } catch (e) {
      print("feedback error: $e");
      return false;
    }
  }
}
