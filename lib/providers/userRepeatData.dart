import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepeatViewModel extends ChangeNotifier {
  int _mantraRepeatMode = 1;

  int get mantraRepeatMode => _mantraRepeatMode;

  UserRepeatViewModel() {
    getRepeatMode();
  }

  getRepeatMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _mantraRepeatMode = prefs.getInt("repeatMantraMode") ?? 1;
    notifyListeners();
  }

  saveSharedPref(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("repeatMantraMode", count);
  }

  changeMode(int count) {
    _mantraRepeatMode = count;
    saveSharedPref(count);
    notifyListeners();
  }
}
