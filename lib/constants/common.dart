import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

import '../model/mantraData.dart';

Future<bool> checkPermission() async {
  TargetPlatform platform;
  if (Platform.isAndroid) {
    platform = TargetPlatform.android;
  } else {
    platform = TargetPlatform.iOS;
  }
  print(platform);
  if (platform == TargetPlatform.android) {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      // print("Raised");
      final result = await Permission.unknown.request();
      final result2 = await Permission.storage.request();
      final result3 = await Permission.audio.request();
      final result4 = await Permission.accessMediaLocation.request();
      final result5 = await Permission.mediaLibrary.request();
      if (result == PermissionStatus.granted) {
        // print("ret true 1");
        return true;
      } else if (result == PermissionStatus.permanentlyDenied){
        // print("Req again");
        var result1 = await Permission.unknown.request();
        // print(result1);
      }
    } else {
      // print("ret true 2");
      return true;
    }
  } else {
    // print("ret true 3");
    return true;
  }
  // print("ret false");
  return false;
}

int getTithiDate(DateTime date, dynamic tithiData){
  DateFormat formatter = DateFormat("yyyy-MM-dd");
  String temp = formatter.format(date);
  // print("Tithi data in func: $tithiData");
  int tithiDate = tithiData[temp]["Tithi"];
  // print("Tithi is: $tithiDate");
  if (tithiDate>15 && tithiDate!=30){
    return tithiDate-15;
  }
  return tithiDate;
}
//
// DateTime getNextTithi(DateTime date,List<MantraModel> mantraData,dynamic tithiData){
//   int currTithi = mantraData
//   var kjasd = getTithiDate(date, tithiData);
//   return date;
// }

