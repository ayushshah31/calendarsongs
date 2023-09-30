import 'package:calendarsong/data/FirebaseFetch.dart';
import 'package:calendarsong/model/mantraData.dart';
import 'package:calendarsong/model/tithiData.dart';
import 'package:flutter/material.dart';

class TithiViewModel extends ChangeNotifier {
  bool _loading = false;
  dynamic _tithiModel = {};
  bool get loading => _loading;
  dynamic get tithiModel => _tithiModel;
  TithiViewModel() {
    // print("here");
    getTithiModel();
  }
  setLoading(bool loading) async {
    _loading = loading;
    notifyListeners();
  }

  setTithiListModel(dynamic tithiListModel) {
    _tithiModel = tithiListModel;
  }

  getTithiModel() async {
    setLoading(true);
    FirebaseFetch ff = FirebaseFetch();
    dynamic response = await ff.getTithiData();
    // print("Tithi pro: $response");
    setTithiListModel(response);
    // print("tithi here got");
    setLoading(false);
  }
}
