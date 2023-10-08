import 'dart:io';

import 'package:calendarsong/Screens/bottomBar.dart';
import 'package:calendarsong/providers/mantraDataProvider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:app_settings/app_settings.dart';

import '../constants/common.dart';
import '../model/mantraData.dart';

class Wrapper extends StatefulWidget {
  Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  double downloadCounter = 0.0;

  String _localPath = "";
  bool _permissionReady = false;
  bool _downloading = true;
  List<MantraModel> mantraData = [];
  bool fileDownloaded = false;

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
      print("Directory created");
      savedDir.create();
      print("Permission Check");
      _permissionReady = await checkPermission();
      print("Permission in wrapper: ${_permissionReady}");
      setState(() {});
      if (_permissionReady) {
        await download();
      }
    } else {
      String check = "$_localPath${Platform.pathSeparator}${mantraData[0].introSoundFile}";
      // print("Mantra path exists");
      final filePath = File(check);
      // print("FilePath: $filePath");
      final fileExists = await filePath.exists();
      String check2 = "$_localPath${Platform.pathSeparator}${mantraData[15].introSoundFile}";
      final filePath2 = File(check2);
      print("FilePathDownCheck: ${filePath2.exists()},$filePath2");
      if (fileExists && await filePath2.exists()) {
        // print("Mantras exists");
        setState(() {
          _downloading = false;
          fileDownloaded = true;
          downloadCounter = 100;
        });
      } else {
        await download();
      }
    }
  }

  Future<void> download() async {
    setState(() {
      _downloading = true;
    });
    print("Downloading");
    try {
      for (int i = 0; i < mantraData.length; i++) {
        await Dio().download(mantraData[i].introLink,
            "$_localPath${Platform.pathSeparator}${mantraData[i].introSoundFile}");
        setState(() {
          downloadCounter += 100 / 32;
        });
        print(downloadCounter);
        final cheker =
            await File("$_localPath${Platform.pathSeparator}${mantraData[i].introSoundFile}")
                .exists();
        print(cheker);
        await Dio().download(mantraData[i].mantraLink,
            "$_localPath${Platform.pathSeparator}${mantraData[i].mantraSoundFile}");
        setState(() {
          downloadCounter += 100 / 32;
        });
        print(downloadCounter);
        final cheker1 =
            await File("$_localPath${Platform.pathSeparator}${mantraData[i].mantraSoundFile}")
                .exists();
        print(cheker1);
      }
      // await Dio().download(mantra[0]['link'],
      //     "$_localPath/0.mp3");
      print("Download Completed.");
      String check = "$_localPath${Platform.pathSeparator}${mantraData[0].introSoundFile}";
      final filePath1 = File(check);
      // print("FilePathDownCheck: ${filePath1.exists()},$filePath1");
      String check2 = "$_localPath${Platform.pathSeparator}${mantraData[15].introSoundFile}";
      final filePath2 = File(check2);
      // print("FilePathDownCheck: ${filePath2.exists()},$filePath2");
      // if(await filePath2.exists() && await filePath1.exists()){
      //   return;
      // }
      setState(() {
        _downloading = false;
      });
      if (await filePath1.exists() && await filePath2.exists()) {
        setState(() {
          fileDownloaded = true;
        });
      }
    } catch (e) {
      print("Download Failed: $e");
      setState(() {
        _downloading = false;
        // fileDownloaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    internetChecker();
    versionChecker();
  }

  void initDownload() async {
    // await Future.delayed(Duration(seconds: 5),() async{
    print("Now start");
    await _downloadMantra("mantra");
    // });
  }

  bool request = false;
  bool internet = false;
  var listener;
  int versionNumber = 0;

  void versionChecker() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      print('Android $release (SDK $sdkInt), $manufacturer $model');
      versionNumber = sdkInt;
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
    }

    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      print('$systemName $version, $name $model');
      // iOS 13.1, iPhone 11 Pro Max iPhone
    }
  }

  internetChecker() async {
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is available.');
          setState(() {
            internet = true;
          });
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          setState(() {
            internet = false;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.height * 0.028;
    if (!_permissionReady) {
      checkPermission().then((value) {
        _permissionReady = value;
        print("Checking");
        if (_permissionReady) {
          initDownload();
        }
      });
    }
    mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    // if(user == null) {
    //   return const SignUp();
    // }
    if (mantraData.isNotEmpty && !request) {
      print("start");
      request = true;
      initDownload();
    }

    if (!internet) {
      return Scaffold(
        backgroundColor: const Color(0xfff8dbc1),
        appBar: AppBar(
          title: const Text("Mantra Therapy"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(
                flex: 2,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Please check your internet connection.",
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  AppSettings.openAppSettings(type: AppSettingsType.wireless);
                },
                child: const Text("Open Settings"),
              ),
              Spacer(
                flex: 2,
              )
            ],
          ),
        ),
      );
    }

    if (_downloading) {
      return Scaffold(
        backgroundColor: const Color(0xfff8dbc1),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
              child: Visibility(
            visible: _permissionReady,
            replacement: Column(
              mainAxisAlignment:
                  versionNumber < 29 ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                versionNumber < 29
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                        child: Text(
                          "The Mantra Therapy app downloads Hindu calendar and mantra files from the server. "
                          "In order for you to use this app, please provide STORAGE permissions to this App"
                          "\n1. Click on 'Open Settings' button below"
                          "\n2. Scroll and click on PERMISSIONS "
                          "\n3. Click on STORAGE and select ALLOW"
                          "\n4. And then come back to this Application (by hitting BACK button couple of times)",
                          style: TextStyle(fontSize: fontSize),
                          textAlign: TextAlign.start,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
                        child: Text(
                          "We Download Mantra Data from the server so you will have to give download permission to this app.",
                          style: TextStyle(fontSize: fontSize),
                          textAlign: TextAlign.center,
                        ),
                      ),
                // const SizedBox(height: 20),
                // const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: ElevatedButton(
                    onPressed: () {
                      AppSettings.openAppSettings();
                    },
                    child: const Text("Open Settings"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                  child: Text(
                    "Once you have above permission, click below button to Reload",
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.start,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text("Reload"),
                  ),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitFoldingCube(
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  "Gathering Data $downloadCounter",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          )),
        ),
      );
    } else {
      return BottomBarController();
    }
  }
}
