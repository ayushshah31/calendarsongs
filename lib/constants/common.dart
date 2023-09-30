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
      // final result = await Permission.unknown.request();
      // final result2 = await Permission.storage.request();
      final result = await Permission.audio.request();
      // final result1 = await Permission.accessMediaLocation.request();
      // final result4 = await Permission.mediaLibrary.request();
      print("prm: $result");
      if (result == PermissionStatus.granted) {
        print("ret true 1");
        return true;
      } else if (result == PermissionStatus.permanentlyDenied) {
        print("Req again");
        var result1 = await Permission.audio.request();
        print(result1);
      }
    } else {
      print("ret true 2");
      return true;
    }
  } else if (platform == TargetPlatform.iOS) {
    print("In else if");
    final status = await Permission.storage.status;
    print("Status: $status");
    final result3 = await Permission.audio.request();
    final result5 = await Permission.unknown.request();
    final result2 = await Permission.storage.request();
    final result1 = await Permission.audio.request();
    // final result = await Permission.accessMediaLocation.request();
    final result4 = await Permission.mediaLibrary.request();
    final result = await Permission.accessMediaLocation.request();
    print("prm: $result,$result1,$result2,$result3,$result4,$result5");
    if (status != PermissionStatus.granted) {
      if (result == PermissionStatus.granted) {
        print("prm: $result,$result1,$result2,$result3,$result4,$result5");
        return true;
      }
    } else {
      return true;
    }
    // print("ret true 3");
  }
  print("ret false");
  return false;
}

int getTithiDate(DateTime date, dynamic tithiData) {
  DateFormat formatter = DateFormat("yyyy-MM-dd");
  String temp = formatter.format(date);
  // print("Tithi data in func: $tithiData");
  int tithiDate = tithiData[temp]["Tithi"];
  // print("Tithi is: $tithiDate");
  if (tithiDate > 15 && tithiDate != 30) {
    return tithiDate - 15;
  }
  return tithiDate;
}
