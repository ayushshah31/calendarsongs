import 'package:calendarsong/data/FirebaseFetch.dart';
import 'package:calendarsong/model/mantraData.dart';
import 'package:flutter/material.dart';
class MantraViewModel extends ChangeNotifier {

  bool _loading = false;
  List<MantraModel> _mantraModel = [];
  bool get loading => _loading;
  List<MantraModel> get mantraModel => _mantraModel;
  MantraViewModel(){
    // print("here");
    getMantraModel();
  }
  setLoading(bool loading) async {
    _loading = loading;
    notifyListeners();
  }
  setMantraListModel(List<MantraModel> mantraListModel) {
    _mantraModel = mantraListModel;
    // print("MantraModel in Provider: ${_mantraModel}");
  }
  getMantraModel() async {
    setLoading(true);
    FirebaseFetch ff= FirebaseFetch();
    var response = await ff.getMantraDataPro();
    // print("mantra here: ${response[0]}");
    setMantraListModel(response as List<MantraModel>);
    // print("DATA done");
    setLoading(false);
  }
}