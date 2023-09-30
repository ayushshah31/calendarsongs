import 'dart:io';
import 'dart:math';

import 'package:calendarsong/model/mantraData.dart';
import 'package:calendarsong/providers/mantraDataProvider.dart';
import 'package:calendarsong/providers/tithiDataProvider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/common.dart';
import '../constants/routes.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';

import 'package:advanced_in_app_review/advanced_in_app_review.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class DataRequiredForBuild {
  List mantraData;
  dynamic tithiData;
  DataRequiredForBuild({required this.mantraData, required this.tithiData});
}

class _HomePageState extends State<HomePage> {
  bool introPlaying = true;
  dynamic tithiData = {};

  late Future<DataRequiredForBuild> _dataRequiredForBuild;
  Future<DataRequiredForBuild> _fetchData() async {
    // final _firebaseFetch = FirebaseFetch();
    // mantra = await _firebaseFetch.getMantra();
    print("Mantra rec: $mantraData");
    // print("MantraData rec: $mantraData");
    // print("Tithi rec: $tithiData");
    // _downloadMantra("mantra");
    shareMsg =
        (await _databaseRef.child("share").child("message").once()).snapshot.value.toString();
    if (Platform.isAndroid) {
      shareTxt = (await _databaseRef.child("share").child("text").once()).snapshot.value.toString();
    } else if (Platform.isIOS) {
      shareTxt =
          (await _databaseRef.child("share").child("textIOS").once()).snapshot.value.toString();
    }
    // shareTxt = (await _databaseRef.child("share").child("text").once()).snapshot.value.toString();
    return DataRequiredForBuild(mantraData: mantraData, tithiData: tithiData);
  }

  String _platformVersion = 'Unknown';

  bool loadSliderMax = false;
  double sliderMax = 1;

  Color button1Text = Color(0xff80571d);
  Color button2Text = Color(0xff80571d);
  Color button3Text = Color(0xff80571d);
  Color button4Text = Color(0xff80571d);
  Color button5Text = Color(0xff80571d);

  bool button1Pressed = false;
  bool button2Pressed = false;
  bool button3Pressed = false;
  bool button4Pressed = false;
  bool button5Pressed = false;

  @override
  void initState() {
    print("In INIT");
    super.initState();
    _dataRequiredForBuild = _fetchData();
    getIt<PageManager>().init();
    initPlatformState();
    AdvancedInAppReview()
        .setMinDaysBeforeRemind(10)
        .setMinDaysAfterInstall(2)
        .setMinLaunchTimes(2)
        .setMinSecondsBeforeShowDialog(30)
        .monitor();
    // _downloadMantra("mantra");
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await AdvancedInAppReview.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
    print("platform: ${_platformVersion}");
  }

  Future<void> setData() async {
    print("SET DATA BUILT");
    res = getTithiDate(DateTime.now(), tithiData);
    res2 = getTithiMantraData(res);
    currTithi = res2.tithi;
  }

  // @override
  // void dispose() {
  //   getIt<PageManager>().dispose();
  //   super.dispose();
  // }

  // Future<void> setAudioPlayer() async{
  //   await setupServiceLocator();
  // }

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  int mantraCounter = 0;

  late TargetPlatform? platform;
  bool isMantraDown = false;

  List<MantraModel> mantraData = [];
  DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  String shareTxt = "", shareMsg = "";

  int res = -1;
  MantraModel res2 = MantraModel();
  late int currTithi;

  void setFocusedDay(DateTime focusedDayNew) {
    setState(() {
      focusedDay = focusedDayNew;
    });
  }

  void setMantraCount(int newCount) {
    setState(() {
      mantraCounter = newCount;
    });
  }

  late PageController pageController = PageController();

  void setPageController(PageController controller) {
    // setState(() {
    pageController = controller;
    // });
  }

  MantraModel getTithiMantraData(int currTithi) {
    MantraModel ans = MantraModel();
    for (int i = 0; i < mantraData.length; i++) {
      if (mantraData[i].tithi == currTithi) {
        // print(mantraData[i]);
        ans = mantraData[i];
        break;
      }
    }
    return ans;
  }

  List weekday = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  List months = [
    "Jan",
    "Feb",
    "March",
    "April",
    "May",
    "June",
    "July",
    "Aug",
    "Sept",
    "Oct",
    "Nov",
    "Dec"
  ];
  String selsup(int dateNow) {
    String th = "\u1d57\u02b0";
    String rd = "\u02b3\u1d48";
    String nd = "\u207f\u1d48";
    String st = "\u02e2\u1d57";
    var res = dateNow.toString().split("");
    if (res.last == "1") {
      return st;
    } else if (res.last == "2") {
      return nd;
    } else if (res.last == "3") {
      return rd;
    } else {
      return th;
    }
  }

  String getTodayDate() {
    int day = DateTime.now().day;
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    String supText = selsup(day);
    return "${day}${supText} ${months[month - 1]} $year";
  }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    Duration current = const Duration();
    mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    tithiData = Provider.of<TithiViewModel>(context).tithiModel;
    // double sliderMax = 1;
    bool maxSet = false;
    if (res == -1) {
      setData();
    }
    void changeMantra() {
      setState(() {
        if (pageManager.repeatCounterNotifier.value >= 0) {
          pageManager.clearQueue(res);
        } else {
          print("change here");
          pageManager.remove();
          pageManager.remove();
          pageManager.remove();
          pageManager.remove();
        }
        pageManager.add(res, "Intro");
        print("Should Change");
        introPlaying = true;
        pageManager.pause();
        pageManager.seek(Duration.zero);
        pageManager.repeatButtonNotifier.value = RepeatState.repeatSong;
        pageManager.repeatCounterNotifier.value = 0;
        pageManager.repeat();
        mantraCounter = 0;
        button1Pressed = button2Pressed = button3Pressed = button4Pressed = button5Pressed = false;
        maxSet = false;
        loadSliderMax = false;
        sliderMax = 1;
      });
    }

    // void setSelectedDay(DateTime selectedDayNew) async {
    //   // await pageManager.clearQueue();
    //   setState(() {
    //     selectedDay = selectedDayNew;
    //     // pageManager.removeAll();
    //   });
    // }

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        // title: const Text("Mantra Therapy"),
        // automaticallyImplyLeading: false,
        // actions: [
        // PopupMenuButton(
        // icon: Image.asset(
        //   "lib/assets/images/more.png",
        //   color: Colors.white,
        // ),
        // position: PopupMenuPosition.under,
        // onSelected: (value) {
        //   switch (value) {
        // case 0:
        //   Navigator.pushNamed(context, playlists);
        //   break;
        // case 1:
        //   const snackBar = SnackBar(
        //     content: Text("Feature not available in your location"),
        //     duration: Duration(seconds: 3),
        //   );
        //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
        //   break;
        // case 2:
        //   Navigator.pushNamed(context, feedback);
        //   break;
        // case 3:
        //   Share.share(shareTxt, subject: shareMsg);
        //   break;
        // case 4 :
        //   signOutDialogBox();
        //   break;
        // }
        // },
        // itemBuilder: (context) => [
        // const PopupMenuItem(
        //   value: 0,
        //   padding: EdgeInsets.symmetric(horizontal: 10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text("Playlists"),
        //       SizedBox(width:10),
        //       Icon(Icons.playlist_add,color: Colors.black,)
        //     ],
        //   ),
        //   // onTap: ,
        // ),
        // const PopupMenuItem(
        //   value: 1,
        //   padding: EdgeInsets.symmetric(horizontal: 10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text("Get Pro"),
        //       SizedBox(width: 10),
        //       Icon(
        //         Icons.paid_rounded,
        //         color: Colors.black,
        //       )
        //     ],
        //   ),
        // ),
        // const PopupMenuItem(
        //   value: 2,
        //   padding: EdgeInsets.symmetric(horizontal: 10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text("Feedback"),
        //       SizedBox(width: 10),
        //       Icon(
        //         Icons.mail,
        //         color: Colors.black,
        //       )
        //     ],
        //   ),
        // ),
        // const PopupMenuItem(
        //     value: 3,
        //     padding: EdgeInsets.symmetric(horizontal: 10),
        //     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //       Text("Share"),
        //       SizedBox(width: 10),
        //       Icon(
        //         Icons.ios_share_outlined,
        //         color: Colors.black,
        //       ),
        //     ])),
        // const PopupMenuItem(
        //   value: 4,
        //   padding: EdgeInsets.symmetric(horizontal: 10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text("SignOut"),
        //       SizedBox(width:10),
        //       Icon(Icons.person,color: Colors.black,)
        //     ],
        //   ),
        // ),
        //             ])
        //   ],
        // ),
        backgroundColor: const Color(0xfff8dbc1),
        body: Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // HomeCalendarState(
            //     setPageController: setPageController,
            //     pageController: pageController,
            //     selectedDay: selectedDay,
            //     setSelectedDay: setSelectedDay,
            //     focusedDay: focusedDay,
            //     setFocusedDay: setFocusedDay,
            //     mantraCounter: mantraCounter,
            //     setMantraCounter: setMantraCount,
            //     // pageController: pageControllerCal,
            //     // getTithiDate: getTithiDate,
            //     // setAudioPlayer: setAudioPlayer
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await setData();
                    changeMantra();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // border: Border(
                      //   left: BorderSide(
                      //     color: Colors.black,
                      //   ),
                      //   right: BorderSide(color: Colors.black),
                      //   top: BorderSide(color: Colors.black),
                      //   bottom: BorderSide(color: Colors.black)
                      // ),
                      border: Border.all(color: Color(0xff80571d), width: 2),
                      // color: Color(0xFFf3ae85)
                    ),
                    child: Column(children: [
                      Text(
                        weekday[DateTime.now().weekday - 1],
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: Color(0xff80571d),
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(getTodayDate(),
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                              color: Color(0xff80571d),
                              fontWeight: FontWeight.w500))
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black), color: Color(0xFFf3ae85)),
                      child: Column(children: [
                        Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          alignment: WrapAlignment.center,
                          // alignment: WrapAlignment.center,
                          children: [
                            Text(
                              "Tithi",
                              // textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.057,
                                  fontWeight: FontWeight.w500),
                            ),
                            // SizedBox(width: 5),
                            Text(
                              res == 15 || res == 30
                                  ? res2.introSoundFile.toString().split(" ")[0]
                                  : res2.introSoundFile.toString().split(" ")[1],
                              // textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.057,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.redAccent),
                            )
                          ],
                        ),
                        Wrap(
                          spacing: 10,
                          // alignment: WrapAlignment.spaceEvenly,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  // DateTime? newDay = selectedDay;
                                  // var tithiNew = res2.tithi;
                                  // while(tithiNew == res2.tithi) {
                                  //   newDay = newDay!.subtract(const Duration(days: 1));
                                  //   print(newDay);
                                  //   // var tithiNew = res2.tithi;
                                  //   var resNew = getTithiDate(newDay, tithiData);
                                  //   MantraModel resNew2 = getTithiMantraData(resNew);
                                  //   tithiNew = resNew2.tithi;
                                  // }
                                  // setSelectedDay(newDay!);
                                  // setFocusedDay(newDay);
                                  // print("Tapped");
                                  // print("curr $currTithi");
                                  currTithi = currTithi - 1;
                                  // print("Tapped");
                                  // print("curr $currTithi");
                                  if (currTithi <= 15 && currTithi >= 1) {
                                    setState(() {
                                      res = currTithi;
                                      res2 = getTithiMantraData(currTithi);
                                    });
                                  } else if (currTithi > 15 && currTithi < 30) {
                                    setState(() {
                                      res = currTithi - 15;
                                      res2 = getTithiMantraData(currTithi - 15);
                                    });
                                  } else if (currTithi <= 0) {
                                    setState(() {
                                      res2 = getTithiMantraData(30);
                                      currTithi = 30;
                                      res = 30;
                                    });
                                  }
                                  changeMantra();
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                    foregroundColor: MaterialStateProperty.all(Colors.white)),
                                child: const Text("< Prev Tithi")),
                            OutlinedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                    foregroundColor: MaterialStateProperty.all(Colors.white)),
                                onPressed: () {
                                  // DateTime? newDay = selectedDay;
                                  // var tithiNew = res2.tithi;
                                  // while(tithiNew == res2.tithi) {
                                  //   newDay = newDay!.add(const Duration(days: 1));
                                  //   print(newDay);
                                  //   // var tithiNew = res2.tithi;
                                  //   var resNew = getTithiDate(newDay, tithiData);
                                  //   MantraModel resNew2 = getTithiMantraData(resNew);
                                  //   tithiNew = resNew2.tithi;
                                  // }
                                  // setSelectedDay(newDay!);
                                  // setFocusedDay(newDay);
                                  // print("Tapped +");
                                  // print("curr $currTithi");
                                  currTithi += 1;
                                  // print("Tapped +");
                                  // print("curr $currTithi");
                                  if (currTithi <= 15 && currTithi >= 1) {
                                    setState(() {
                                      res = currTithi;
                                      res2 = getTithiMantraData(currTithi);
                                    });
                                  } else if (currTithi > 15 && currTithi < 30) {
                                    setState(() {
                                      res = currTithi - 15;
                                      res2 = getTithiMantraData(currTithi - 15);
                                    });
                                  } else if (currTithi == 30) {
                                    setState(() {
                                      res = 30;
                                      res2 = getTithiMantraData(30);
                                    });
                                  } else if (currTithi > 30) {
                                    setState(() {
                                      currTithi = 1;
                                      res = currTithi;
                                      res2 = getTithiMantraData(currTithi);
                                    });
                                  }
                                  changeMantra();
                                },
                                child: const Text("Next Tithi >"))
                          ],
                        )
                      ]),
                    ))
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                child: ValueListenableBuilder<ProgressBarState>(
                  valueListenable: pageManager.progressNotifier,
                  builder: (_, value, __) {
                    // print("value.curr: ${value.current}");
                    // print("tot val: ${value.total}");
                    current = value.current;
                    // sliderMax = pageManager.mantraDuration!.inMilliseconds.toDouble() ?? Duration.zero.inMilliseconds.toDouble();
                    // if (!introPlaying && !maxSet) {
                    //   // sliderMax = value.total.inMilliseconds.toDouble();
                    //   sliderMax = pageManager.progressNotifier.value.total.inMilliseconds.toDouble();
                    //   print("SliderMax: $sliderMax");
                    //   maxSet = true;
                    // }
                    // print("SliderMaxxxx: $sliderMax");
                    return Row(
                      children: [
                        Text("00:${value.current.inSeconds % 60}"),
                        Expanded(
                          flex: 4,
                          child: Slider(
                              value: min(value.current.inMilliseconds.toDouble(),
                                  max(value.total.inMilliseconds.toDouble(), sliderMax)),
                              min: 0.0,
                              divisions: max(sliderMax.toInt() + 1, value.total.inMilliseconds + 1),
                              max: max(sliderMax.toInt() + 10, value.total.inMilliseconds + 10),
                              onChanged: (val) {
                                pageManager.seek(Duration(milliseconds: val.toInt()));
                              }),
                        ),
                        Text("00:${max(sliderMax ~/ 1000, value.total.inMilliseconds ~/ 1000)}"),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ValueListenableBuilder<int>(
            //   valueListenable: pageManager.repeatCounterNotifier,
            //   builder: (context, value, _) {
            //    return !(mantraCounter>110)?Text("Repeat: $mantraCounter",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,),)
            //        :Text("Repeat: ∞",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,),);
            //   },
            // ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              // Expanded(
              //   flex: 2,
              //   child: Container(
              //     margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              //     child: ValueListenableBuilder<int>(
              //       valueListenable: pageManager.repeatCounterNotifier,
              //       builder: (context, value, _) {
              //         return !(mantraCounter > 110)
              //             ? Text(
              //                 "Repeat: $value",
              //                 style: TextStyle(
              //                   fontSize: MediaQuery.of(context).size.width * 0.04,
              //                 ),
              //               )
              //             : Text(
              //                 "Repeat: ∞",
              //                 style: TextStyle(
              //                   fontSize: MediaQuery.of(context).size.width * 0.045,
              //                 ),
              //               );
              //       },
              //     ),
              //   ),
              // ),
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => pageManager.prev5(current),
                      icon: const Icon(Icons.replay_5),
                    ),
                    // RepeatButton(),
                    ValueListenableBuilder<RepeatState>(
                      valueListenable: pageManager.repeatButtonNotifier,
                      builder: (context, value, child) {
                        Icon icon;
                        switch (value) {
                          case RepeatState.off:
                            icon = const Icon(Icons.repeat, color: Colors.grey);
                            break;
                          case RepeatState.repeatSong:
                            if (introPlaying) {
                              print("Intro Playing");
                              print("counter val: ${pageManager.repeatCounterNotifier.value}");
                              icon = const Icon(Icons.repeat, color: Colors.grey);
                              break;
                            }
                            icon = const Icon(Icons.repeat_one);
                            break;

                          // case RepeatState.repeatCount:
                          //   // if(mantraCounter>0){
                          //   //   // print("MantraCounter $mantraCounter");
                          //   //   // pageManager.remove();
                          //   //   // pageManager.add(res,"mantra");
                          //   //   // introPlaying = false;
                          //   //   // mantraCounter-=1;
                          //   //   // print("MantraCounter $mantraCounter");
                          //   //   // pageManager.play;
                          //   //   // pageManager.repeat();
                          //   //   // pageManager.
                          //   // }
                          //   icon = const Icon(Icons.add_a_photo);
                          //   break;
                        }
                        return IconButton(
                          icon: icon,
                          onPressed: () => pageManager.repeat(),
                        );
                      },
                    ),

                    // PreviousSongButton(),
                    //No Previous button

                    // PlayButton(),
                    ValueListenableBuilder<ButtonState>(
                      valueListenable: pageManager.playButtonNotifier,
                      builder: (_, value, __) {
                        switch (value) {
                          case ButtonState.loading:
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 32.0,
                              height: 32.0,
                              child: const CircularProgressIndicator(),
                            );
                          case ButtonState.paused:
                            return IconButton(
                              icon: const Icon(Icons.play_arrow),
                              iconSize: 32.0,
                              onPressed: pageManager.play,
                            );
                          case ButtonState.playing:
                            var total = pageManager.progressNotifier.value.total.inMilliseconds;
                            if (loadSliderMax || sliderMax < total) {
                              print(
                                  "Total: ${pageManager.progressNotifier.value.total.inMilliseconds}");
                              sliderMax = pageManager.progressNotifier.value.total.inMilliseconds
                                  .toDouble();
                              print("SliderMax: $sliderMax");
                              maxSet = true;
                              loadSliderMax = false;
                            }
                            return IconButton(
                              icon: const Icon(Icons.pause),
                              iconSize: 32.0,
                              onPressed: pageManager.pause,
                            );
                          case ButtonState.finished:
                            if (introPlaying) {
                              print("Intro finish");
                              pageManager.remove();
                              pageManager.add(res, "mantra");
                              print("Load mantra");
                              print(
                                  "Total load: ${pageManager.progressNotifier.value.total.inMilliseconds}");
                              introPlaying = false;
                              pageManager.pause();
                              pageManager.play();
                              loadSliderMax = true;
                              // pageManager.duration();
                            }
                            // if (mantraCounter > 0 && mantraCounter < 110) {
                            //   print("MantraCounter $mantraCounter");
                            //   sliderMax = pageManager.progressNotifier.value.total.inMilliseconds.toDouble();
                            //   // pageManager.remove();
                            //   // pageManager.add(res,"mantra");
                            //   // introPlaying = false;
                            //   mantraCounter -= 1;
                            //   // print("MantraCounter $mantraCounter");
                            //   // // pageManager.stop();
                            //   // pageManager.play();
                            //   // // pageManager.pause();
                            // }
                            return IconButton(
                              icon: const Icon(Icons.play_arrow),
                              iconSize: 32.0,
                              onPressed: () {
                                print("finis");
                                pageManager.seek(Duration.zero);
                              },
                            );
                        }
                      },
                    ),
                    IconButton(
                        onPressed: () => pageManager.next5(current),
                        icon: const Icon(Icons.forward_5))
                    // NextSongButton(),
                    // ShuffleButton(),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Expanded(
                flex: 2,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  // direction: Axis.vertical,
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Repeat Mantra:",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    // OutlinedButton(
                    //   style: ButtonStyle(
                    //   ),
                    //     onPressed: (){
                    //       setState((){
                    //         mantraCounter = 1;
                    //       });
                    //     },
                    //     child: const Text("1")
                    // ),
                    // const Spacer(flex: 1),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          button1Pressed = true;
                          button2Pressed = false;
                          button3Pressed = false;
                          button4Pressed = false;
                          button5Pressed = false;
                          mantraCounter = 1;
                          pageManager.repeatMantraCount(1, res);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(3, 10, 3, 10),
                        margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff80571d)),
                          borderRadius: BorderRadius.circular(10),
                          color: button1Pressed ? Color(0xff80571d) : Colors.transparent,
                        ),
                        child: Text(
                          "1",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: !button1Pressed ? Color(0xff80571d) : Color(0xfff8dbc1)),
                        ),
                      ),
                    ),
                    // const Spacer(flex: 1),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          button2Pressed = true;
                          button1Pressed = false;
                          button3Pressed = false;
                          button4Pressed = false;
                          button5Pressed = false;
                          mantraCounter = 27;
                          pageManager.repeatMantraCount(27, res);
                          pageManager.pause();
                          pageManager.play();
                          // pageManager.add(res, "mantra");
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(4, 10, 4, 10),
                        margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff80571d)),
                          borderRadius: BorderRadius.circular(10),
                          color: button2Pressed ? Color(0xff80571d) : Colors.transparent,
                        ),
                        child: Text(
                          "27",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: !button2Pressed ? Color(0xff80571d) : Color(0xfff8dbc1)),
                        ),
                      ),
                    ),
                    // const Spacer(flex: 1),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          button3Pressed = true;
                          button2Pressed = false;
                          button1Pressed = false;
                          button4Pressed = false;
                          button5Pressed = false;
                          mantraCounter = 54;
                          pageManager.repeatMantraCount(54, res);
                          pageManager.pause();
                          pageManager.play();
                          // pageManager.add(res, "mantra");
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(4, 10, 4, 10),
                        margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff80571d)),
                          borderRadius: BorderRadius.circular(10),
                          color: button3Pressed ? Color(0xff80571d) : Colors.transparent,
                        ),
                        child: Text(
                          "54",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: !button3Pressed ? Color(0xff80571d) : Color(0xfff8dbc1)),
                        ),
                      ),
                    ),
                    // const Spacer(flex: 1),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          button4Pressed = true;
                          button2Pressed = false;
                          button3Pressed = false;
                          button1Pressed = false;
                          button5Pressed = false;
                          mantraCounter = 108;
                          pageManager.repeatMantraCount(108, res);
                          pageManager.pause();
                          pageManager.play();
                          // pageManager.add(res, "mantra");
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(3, 10, 3, 10),
                        margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff80571d)),
                          borderRadius: BorderRadius.circular(10),
                          color: button4Pressed ? Color(0xff80571d) : Colors.transparent,
                        ),
                        child: Text(
                          "108",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: !button4Pressed ? Color(0xff80571d) : Color(0xfff8dbc1)),
                        ),
                      ),
                    ),
                    // const Spacer(flex: 1),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          button5Pressed = true;
                          button2Pressed = false;
                          button3Pressed = false;
                          button4Pressed = false;
                          button1Pressed = false;
                          mantraCounter = 99999999;
                          pageManager.repeat();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(3, 10, 3, 10),
                        margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff80571d)),
                          borderRadius: BorderRadius.circular(10),
                          color: button5Pressed ? Color(0xff80571d) : Colors.transparent,
                        ),
                        child: Text(
                          "Infinite",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: !button5Pressed ? Color(0xff80571d) : Color(0xfff8dbc1)),
                        ),
                      ),
                    ),

                    // const Spacer(flex: 1),
                    // OutlinedButton(
                    //     onPressed: () async{
                    //       setState((){
                    //         mantraCounter = 27;
                    //       });
                    //     },
                    //     child: const Text("27")
                    // ),
                    // // const Spacer(flex: 1),
                    // OutlinedButton(
                    //     onPressed: ()async{
                    //       setState((){
                    //         mantraCounter = 54;
                    //       });
                    //     },
                    //     child: const Text("54")
                    // ),
                    // // const Spacer(flex: 1),
                    // OutlinedButton(
                    //     onPressed: () async{
                    //       setState((){
                    //         mantraCounter = 108;
                    //       });
                    //     },
                    //     child: const Text("108")
                    // ),
                    // // const Spacer(flex: 1),
                    // OutlinedButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         mantraCounter = 999;
                    //       });
                    //     },
                    //     child: const Text("Infinite")
                    // ),
                  ],
                )),
            // TextButton(
            //   onPressed: (){
            //     pageManager.repeatMantraCount(10, res);
            //   },
            //   child: Text("Press"),
            // ),
            // TextButton(
            //   onPressed: (){
            //     pageManager.clearQueue(res);
            //   },
            //   child: Text("clean"),
            // ),
            // const SizedBox(height: 10),
            Expanded(
              flex: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height / 2 + 100,
                child: Scrollbar(
                  // interactive: false,
                  // thickness: 1.5,
                  // thumbVisibility: true,
                  // trackVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mantra:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                "${res2.mantraEnglish}",
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "${res2.mantraHindi}",
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ])),
                        // Spacer(),
                        const SizedBox(height: 10),
                        const Text(
                          "Procedure: ",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            res2.procedure,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Benefit: ",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            res2.benefits,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        // const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Expanded(
            //   flex: 15,
            //   child: Padding(
            //     padding: const EdgeInsets.all(10.0),
            //     child: SingleChildScrollView(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Column(
            //             children: [
            //               Table(
            //                 columnWidths: const {
            //                   0: IntrinsicColumnWidth(flex: 2),
            //                   1: FlexColumnWidth(5)
            //                 },
            //                 children: [
            //                   // TableRow(
            //                   //     children: [
            //                   //
            //                   //     ]
            //                   // ),
            //                   // TableRow(
            //                   //     children: [
            //                   //       // Container(),
            //                   //
            //                   //     ]
            //                   // ),
            //                   TableRow(children: [Container(height: 10), Container()]),
            //                   TableRow(children: [
            //                     const Text(
            //                       "Mantra:",
            //                       style: TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     ),
            //                     Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text(
            //                           "${res2.mantraEnglish}",
            //                           overflow: TextOverflow.visible,
            //                           style: TextStyle(
            //                             fontSize: 18,
            //                           ),
            //                         ),
            //                         SizedBox(height: 10),
            //                         Text(
            //                           "${res2.mantraHindi}",
            //                           overflow: TextOverflow.visible,
            //                           style: TextStyle(
            //                             fontSize: 18,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ]),
            //                   TableRow(children: [Container(height: 15), Container()]),
            //                   TableRow(children: [
            //                     Container(),
            //                     Text(
            //                       res2.noOfRep,
            //                       style: TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     )
            //                   ]),
            //                   TableRow(children: [Container(height: 15), Container()]),
            //                   TableRow(children: [
            //                     const Text(
            //                       "Procedure: ",
            //                       style: TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     ),
            //                     Text(
            //                       res2.procedure,
            //                       style: TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     )
            //                   ]),
            //                   TableRow(children: [Container(height: 15), Container()]),
            //                   TableRow(children: [
            //                     const Text(
            //                       "Benefit: ",
            //                       style: TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     ),
            //                     Text(
            //                       res2.benefits,
            //                       style: TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     )
            //                   ]),
            //                   TableRow(children: [Container(height: 15), Container()]),
            //                 ],
            //               ),
            //             ],
            //           ),
            //           const SizedBox(height: 10),
            //           // const Text("Repeat Mantra: ",style: TextStyle(fontSize: 18,),),
            //           // Row(
            //           //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //           //   children: [
            //           //     OutlinedButton(
            //           //         onPressed: (){
            //           //           setState((){
            //           //             mantraCounter = 1;
            //           //           });
            //           //         },
            //           //         child: const Text("1")
            //           //     ),
            //           //     const Spacer(flex: 1),
            //           //     OutlinedButton(
            //           //         onPressed: () async{
            //           //           setState((){
            //           //             mantraCounter = 27;
            //           //           });
            //           //         },
            //           //         child: const Text("27")
            //           //     ),
            //           //     const Spacer(flex: 1),
            //           //     OutlinedButton(
            //           //         onPressed: ()async{
            //           //           setState((){
            //           //             mantraCounter = 54;
            //           //           });
            //           //         },
            //           //         child: const Text("54")
            //           //     ),
            //           //     const Spacer(flex: 1),
            //           //     OutlinedButton(
            //           //         onPressed: () async{
            //           //           setState((){
            //           //             mantraCounter = 108;
            //           //           });
            //           //         },
            //           //         child: const Text("108")
            //           //     ),
            //           //     const Spacer(flex: 1),
            //           //     OutlinedButton(
            //           //         onPressed: () {
            //           //           setState(() {
            //           //             mantraCounter = 999;
            //           //           });
            //           //         },
            //           //         child: const Text("Infinite")
            //           //     ),
            //           //   ],
            //           // ),
            //           // OutlinedButton(
            //           //     onPressed: (){
            //           //       setState(() {
            //           //         mantraCounter=0;
            //           //       });
            //           //     }, child: const Text("Reset")
            //           // ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // OutlinedButton(
            //     onPressed: () {
            //       // pageManager.removeAll();
            //       setState(() {
            //         mantraCounter = 5;
            //         // for(int i=0;i<5;i++){
            //         //   pageManager.add(res, "mantra");
            //         // }
            //         // pageManager.repeat();
            //       });
            //     },
            //     child: const Text("5")
            // ),
          ]),
        ),
      ),
    );
  }
}

// class RepeatButton extends StatelessWidget {
//   const RepeatButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ;
//   }
// }

// class PreviousSongButton extends StatelessWidget {
//   const PreviousSongButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<bool>(
//       valueListenable: pageManager.isFirstSongNotifier,
//       builder: (_, isFirst, __) {
//         return IconButton(
//           icon: const Icon(Icons.skip_previous),
//           onPressed: (isFirst) ? null : pageManager.previous,
//         );
//       },
//     );
//   }
// }

// class PlayButton extends StatelessWidget {
//   const PlayButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ;
//   }
// }

// class NextSongButton extends StatelessWidget {
//   const NextSongButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<bool>(
//       valueListenable: pageManager.isLastSongNotifier,
//       builder: (_, isLast, __) {
//         return IconButton(
//           icon: const Icon(Icons.skip_next),
//           onPressed: (isLast) ? null : pageManager.next,
//         );
//       },
//     );
//   }
// }
//
// class ShuffleButton extends StatelessWidget {
//   const ShuffleButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return ValueListenableBuilder<bool>(
//       valueListenable: pageManager.isShuffleModeEnabledNotifier,
//       builder: (context, isEnabled, child) {
//         return IconButton(
//           icon: (isEnabled)
//               ? const Icon(Icons.shuffle)
//               : const Icon(Icons.shuffle, color: Colors.grey),
//           onPressed: pageManager.shuffle,
//         );
//       },
//     );
//   }
// }

