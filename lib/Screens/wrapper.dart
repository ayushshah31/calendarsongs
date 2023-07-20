import 'dart:io';

import 'package:calendarsong/Screens/customCalendar.dart';
import 'package:calendarsong/Screens/home.dart';
import 'package:calendarsong/Screens/signUp.dart';
import 'package:calendarsong/providers/mantraDataProvider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../constants/common.dart';
import '../model/mantraData.dart';

class Wrapper extends StatefulWidget {
  Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  String _localPath = "";
  late bool _permissionReady=true;
  bool _downloading = true;
  List<MantraModel> mantraData = [];

  // @override
  // void initState(){
  //   super.initState();
  //   _downloadMantra("mantra");
  // }

  Future<String?> _findLocalPath(String path) async {
    var directory = await getApplicationDocumentsDirectory();
    return '${directory.path}${Platform.pathSeparator}download/$path';
  }

  Future<void> _downloadMantra(String path) async {
    _localPath = (await _findLocalPath(path))!;
    // print(_localPath);
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      // print("Directory created");
      savedDir.create();
      _permissionReady = await checkPermission();
      if (_permissionReady) {
        await download();
      }
    } else {
      String check = "$_localPath${Platform.pathSeparator}${mantraData[0].introSoundFile}";
      // print("Mantra there");
      final filePath = File(check);
      // print("FilePath: $filePath");
      final fileExists = await filePath.exists();
      if(fileExists){
        setState(()=> _downloading=false);
      } else {
        await download();
      }
    }
  }

  Future<void> download() async{
    setState(() {
      _downloading = true;
    });
    print("Downloading");
    try {
      for(int i=0; i<mantraData.length; i++){
        await Dio().download(mantraData[i].introLink, "$_localPath${Platform.pathSeparator}${mantraData[i].introSoundFile}");
        await Dio().download(mantraData[i].mantraLink, "$_localPath${Platform.pathSeparator}${mantraData[i].mantraSoundFile}");
      }
      // await Dio().download(mantra[0]['link'],
      //     "$_localPath/0.mp3");
      print("Download Completed.");
      String check = "$_localPath${Platform.pathSeparator}${mantraData[0].introSoundFile}";
      final filePath = File(check);
      print("FilePathDownCheck: $filePath");
      setState(() {
        _downloading = false;
      });
      // var res = getTithiDate(selectedDay, tithiData);
      // if(res !=30){
      //   setAudioPlayer(res-1);
      // } else {
      //   setAudioPlayer(15);
      // }
    } catch (e) {
      print("Download Failed: $e");
      setState(() {
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    _downloadMantra("mantra");
    if(user == null) {
      return const SignUp();
    }
    if(_downloading){
      return Scaffold(
        backgroundColor: const Color(0xfff8dbc1),
        body: Center(
            child: _permissionReady?Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitFoldingCube(
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                _downloading?const Text("Downloading Data"):const Text("Gathering data")
              ],
            ):const Text("Allow download permissions from settings")),
      );
    }
    return const HomePage();
  }
}
