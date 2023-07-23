import 'dart:io';
import 'dart:math';

import 'package:calendarsong/model/mantraData.dart';
import 'package:calendarsong/providers/mantraDataProvider.dart';
import 'package:calendarsong/providers/tithiDataProvider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../Widgets/homeCalendar.dart';
import '../constants/common.dart';
import '../constants/routes.dart';
import '../data/FirebaseFetch.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class DataRequiredForBuild{
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
    shareMsg = (await _databaseRef.child("share").child("message").once()).snapshot.value.toString();
    shareTxt = (await _databaseRef.child("share").child("text").once()).snapshot.value.toString();
    return DataRequiredForBuild(
        mantraData: mantraData,
        tithiData: tithiData
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dataRequiredForBuild = _fetchData();
    getIt<PageManager>().init();
    // _downloadMantra("mantra");
  }

  Future<void> setData() async{
    res = getTithiDate(DateTime.now(), tithiData);
    res2 = getTithiMantraData(res);
    currTithi = res2.tithi;
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  // Future<void> setAudioPlayer() async{
  //   await setupServiceLocator();
  // }

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  int mantraCounter = 0;

  late String _localPath;
  late TargetPlatform? platform;
  bool isMantraDown = false;
  late bool _permissionReady = true;
  bool _downloading = true;

  List<MantraModel> mantraData = [];
  DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  String shareTxt="",shareMsg="";

  int res = -1;
  MantraModel res2 = MantraModel();
  late int currTithi;


  void setFocusedDay(DateTime focusedDayNew){
    setState(() {
      focusedDay = focusedDayNew;
    });
  }

  void setMantraCount(int newCount){
    setState(() {
      mantraCounter = newCount;
    });
  }

  late PageController pageController = PageController();

  void setPageController(PageController controller){
    // setState(() {
    pageController = controller;
    // });
  }
  MantraModel getTithiMantraData(int currTithi) {
    MantraModel ans = MantraModel();
    for(int i=0; i<mantraData.length;i++){
      if(mantraData[i].tithi==currTithi){
        // print(mantraData[i]);
        ans = mantraData[i];
        break;
      }
    }
    return ans;
  }

  List weekday = [
    "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"
  ];

  List months = [
    "Jan","Feb","March","April","May","June","July","Aug","Sept","Oct","Nov","Dec"
  ];
  String selsup(int dateNow){
    String th = "\u1d57\u02b0";
    String rd = "\u02b3\u1d48";
    String nd = "\u207f\u1d48";
    String st = "\u02e2\u1d57";
    var res = dateNow.toString().split("");
    if(res.last == "1"){
      return st;
    } else if( res.last =="2"){
      return nd;
    } else if(res.last == "3"){
      return rd;
    } else{
      return th;
    }
  }

  String getTodayDate(){
    int day = DateTime.now().day;
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    String supText = selsup(day);
    return "${day}${supText} ${months[month-1]} $year";
  }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    Duration current = const Duration();
    mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    tithiData = Provider.of<TithiViewModel>(context).tithiModel;
    double sliderMax = 1;
    bool maxSet = false;
    if(res == -1) {
      setData();
    }
    void changeMantra(){
      setState(() {
        pageManager.remove();
        pageManager.remove();
        pageManager.add(res, "Intro");
        print("Should Change");
        introPlaying = true;
        pageManager.pause();
        pageManager.seek(Duration.zero);
        pageManager.repeatButtonNotifier.value = RepeatState.repeatSong;
        pageManager.repeatCounterNotifier.value = 0;
        pageManager.repeat();
        mantraCounter = 0;
        pageManager.repeatSet.value = false;
        maxSet = false;
      });
    }

    void setSelectedDay(DateTime selectedDayNew) async{
      // await pageManager.clearQueue();
      setState(() {
        selectedDay = selectedDayNew;
        // pageManager.removeAll();
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mantra Therapy"),
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton(
                icon: Image.asset("lib/assets/images/more.png",color: Colors.white,),
                position: PopupMenuPosition.under,
                onSelected: (value){
                  switch(value){
                    // case 0:
                    //   Navigator.pushNamed(context, playlists);
                    //   break;

                      case 1:
                        const snackBar = SnackBar(content: Text("Feature not available in your location"),duration: Duration(seconds: 3),);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        break;

                      case 2:
                        Navigator.pushNamed(context, feedback);
                        break;

                      case 3:
                        Share.share(shareTxt, subject: shareMsg);
                        break;

                      // case 4 :
                      //   signOutDialogBox();
                      //   break;
                    }
                  },
                  itemBuilder: (context)=>[
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
                    const PopupMenuItem(
                      value: 1,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Get Pro"),
                          SizedBox(width:10),
                          Icon(Icons.paid_rounded,color: Colors.black,)
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Feedback"),
                          SizedBox(width:10),
                          Icon(Icons.mail,color: Colors.black,)
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                        value: 3,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Share"),
                            SizedBox(width: 10),
                            Icon(Icons.ios_share_outlined,color: Colors.black,),
                          ]
                        )
                    ),
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
                  ]
              )
            ],
          ),
          backgroundColor: const Color(0xfff8dbc1),
          body: Container(
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  children: [
                    Container(
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
                        border: Border.all(color: Colors.black),
                        color: Color(0xFFf3ae85)
                      ),
                      child: Column(
                        children: [
                          Text(weekday[DateTime.now().weekday-1],style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05,),),
                          SizedBox(height: 10,),
                          Text(getTodayDate(),style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,),)
                        ]
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tithi ",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,),
                              ),
                              Flexible(
                                child: Text(
                                  res==15||res==30?res2.introSoundFile.toString().split(" ")[0]:res2.introSoundFile.toString().split(" ")[1],
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width*0.049,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.redAccent
                                  ),
                                ),
                              )
                            ],
                          ),
                          Wrap(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                  onPressed: (){
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
                                    // pageManager.clearQueue(res,false);
                                    print("Tapped");
                                    print("curr $currTithi");
                                    currTithi = currTithi - 1;
                                    print("Tapped");
                                    print("curr $currTithi");
                                    int newTithi;
                                    if(currTithi<=15 && currTithi>=1){
                                      setState(() {
                                        res = currTithi;
                                        res2 = getTithiMantraData(currTithi);
                                      });
                                    } else if(currTithi >15 && currTithi<30){
                                      setState(() {
                                        res = currTithi - 15;
                                        res2 = getTithiMantraData(currTithi-15);
                                      });
                                    } else if( currTithi<=0){
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
                                      foregroundColor: MaterialStateProperty.all(Colors.white)
                                  ),
                                  child: const Text("< Prev Tithi")),
                              OutlinedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                      foregroundColor: MaterialStateProperty.all(Colors.white)
                                  ),
                                  onPressed: (){
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
                                    // pageManager.clearQueue(res,false);
                                    print("Tapped +");
                                    print("curr $currTithi");
                                    currTithi += 1;
                                    print("Tapped +");
                                    print("curr $currTithi");
                                    if(currTithi<=15 && currTithi>=1){
                                      setState(() {
                                        res = currTithi;
                                        res2 = getTithiMantraData(currTithi);
                                      });
                                    } else if(currTithi >15 && currTithi<30){
                                      setState(() {
                                        res = currTithi - 15;
                                        res2 = getTithiMantraData(currTithi-15);
                                      });
                                    } else if(currTithi==30){
                                      setState(() {
                                        res = 30;
                                        res2 = getTithiMantraData(30);
                                      });
                                    } else if(currTithi>30){
                                      setState(() {
                                        currTithi = 1;
                                        res = currTithi;
                                        res2 = getTithiMantraData(currTithi);
                                      });
                                    }
                                    changeMantra();
                                  },
                                  child: const Text("Next Tithi >")
                              )
                            ],
                          )
                        ]
                      )
                    )
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
                          if(!introPlaying && mantraCounter>=0 && !maxSet){
                            sliderMax = value.total.inMilliseconds.toDouble();
                            print("SliderMax: $sliderMax");
                            maxSet = true;
                          }
                          return Row(
                            children: [
                              Text("0${value.current.inMinutes}:${value.current.inSeconds%60}"),
                              Expanded(
                                flex: 4,
                                child: Slider(
                                    value: min(value.current.inMilliseconds.toDouble(),max(value.total.inMilliseconds.toDouble(),sliderMax)),
                                    min: 0.0,
                                    divisions: max(sliderMax.toInt()+1,value.total.inMilliseconds+1),
                                    max: pageManager.repeatSet.value?pageManager.repeatCounterDuration.value.inMilliseconds.toDouble():max(sliderMax.toInt()+10,value.total.inMilliseconds+10) ,
                                    onChanged: (val){
                                      pageManager.seek(Duration(milliseconds: val.toInt()));
                                    }
                                ),
                              ),
                              Text("00:${max(sliderMax~/1000,value.total.inMilliseconds~/1000)}"),
                              // pageManager.repeatSet.value?
                              //   Text("${pageManager.repeatCounterDuration.value.inSeconds~/60}:${pageManager.repeatCounterDuration.value.inMilliseconds~/1000}")
                              //   :Text("${max(sliderMax~/60000,value.total.inMilliseconds~/60000)}:${max(sliderMax~/1000,value.total.inMilliseconds~/1000)}"),
                            ],
                          );
                        },
                      ),
                    ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                        child: ValueListenableBuilder<int>(
                          valueListenable: pageManager.repeatCounterNotifier,
                          builder: (context, value, _) {
                            return !(mantraCounter>110)?Text("Repeat: $value",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,),)
                                      :Text("Repeat: ∞",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,),);
                          },
                        ),
                        // child: ValueListenableBuilder<ButtonState>(
                        //     valueListenable: pageManager.playButtonNotifier,
                        //     builder: (_, value, __) {
                        //       // mantraCounter--;
                        //       // print("value: $value");
                        //       return !(mantraCounter>110)?Text("Repeat: $mantraCounter",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04,),)
                        //           :Text("Repeat: ∞",style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045,),);
                        //     }
                        // ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: ()=>pageManager.prev5(current),
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
                                  if(introPlaying){
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
                                onPressed: ()=>pageManager.repeat(),
                              );
                            },
                          ),

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
                                  return IconButton(
                                    icon: const Icon(Icons.pause),
                                    iconSize: 32.0,
                                    onPressed: pageManager.pause,
                                  );
                                case ButtonState.finished:
                                  if(introPlaying){
                                    pageManager.remove();
                                    pageManager.add(res,"mantra");
                                    introPlaying = false;
                                    pageManager.pause;
                                    // sliderMax = repeatCounterDuration.value = _audioHandler.queue.value.first.duration!;
                                    sliderMax = pageManager.progressNotifier.value.total.inMilliseconds.toDouble();
                                  }
                                  if(mantraCounter>0 && mantraCounter<110){
                                    print("MantraCounter $mantraCounter");
                                    // pageManager.remove();
                                    // pageManager.add(res,"mantra");
                                    // introPlaying = false;
                                    mantraCounter-=1;
                                    // print("MantraCounter $mantraCounter");
                                    // // pageManager.stop();
                                    // pageManager.play();
                                    // // pageManager.pause();
                                  }
                                  return IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    iconSize: 32.0,
                                    onPressed: (){
                                      print("finis");
                                      pageManager.seek(Duration.zero);
                                    },
                                  );
                              // TODO: Handle this case.
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
                  ]
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex:10,
                          child: Text("Repeat Mantra:",style: TextStyle(fontSize:18),)
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: (){
                            setState((){
                              mantraCounter = 1;
                              pageManager.clearQueue(res);
                              // pageManager.repeatMantraCount(0, res);
                              // pageManager.repeatSet.value = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(3, 10, 3, 10),
                            decoration: BoxDecoration(
                              border: Border.all(color:Color(0xff80571d) ),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text("1",textAlign: TextAlign.center,),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: (){
                            setState((){
                              mantraCounter = 27;
                              pageManager.clearQueue(res);
                              pageManager.repeatMantraCount(26, res);
                              pageManager.repeatCounterNotifier.value = 27;
                              pageManager.repeatSet.value = true;
                              pageManager.play();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(4, 10, 4, 10),
                            decoration: BoxDecoration(
                                border: Border.all(color:Color(0xff80571d) ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text("27",textAlign: TextAlign.center,),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: (){
                            setState((){
                              mantraCounter = 54;
                              pageManager.clearQueue(res);
                              pageManager.repeatMantraCount(53, res);
                              pageManager.repeatCounterNotifier.value = 54;
                              pageManager.repeatSet.value = true;
                              pageManager.play();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(4, 10, 0, 10),
                            decoration: BoxDecoration(
                                border: Border.all(color:Color(0xff80571d) ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text("54",textAlign: TextAlign.center,),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: (){
                            setState((){
                              mantraCounter = 108;
                              pageManager.clearQueue(res);
                              pageManager.repeatMantraCount(107, res);
                              pageManager.repeatCounterNotifier.value = 108;
                              pageManager.repeatSet.value = true;
                              pageManager.play();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(3, 10, 0, 10),
                            decoration: BoxDecoration(
                                border: Border.all(color:Color(0xff80571d) ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text("108",textAlign: TextAlign.center,),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: (){
                            setState((){
                              mantraCounter = 99999999;
                              pageManager.repeat();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(3, 10, 3, 10),
                            decoration: BoxDecoration(
                                border: Border.all(color:Color(0xff80571d) ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text("Infinite",textAlign: TextAlign.center,),
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
                  )
                ),
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
                const SizedBox(height: 10),
                Expanded(
                  flex: 15,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Table(
                                columnWidths: const {
                                  0: IntrinsicColumnWidth(flex: 2),
                                  1: FlexColumnWidth(5)
                                },
                                children: [
                                  // TableRow(
                                  //     children: [
                                  //
                                  //     ]
                                  // ),
                                  // TableRow(
                                  //     children: [
                                  //       // Container(),
                                  //
                                  //     ]
                                  // ),
                                  TableRow(
                                    children: [
                                      Container(height: 10),
                                      Container()
                                    ]
                                  ),
                                  TableRow(
                                      children: [
                                        const Text("Mantra:",style: TextStyle(fontSize: 18,),),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                          ],
                                        ),
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        Container(height:15),
                                        Container()
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        Container(),
                                        Text(res2.noOfRep,style: TextStyle(fontSize: 18,),)
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        Container(height:15),
                                        Container()
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        const Text("Procedure: ",style: TextStyle(fontSize: 18,),),
                                        Text(res2.procedure,style: TextStyle(fontSize: 18,),)
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        Container(height:15),
                                        Container()
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        const Text("Benefit: ",style: TextStyle(fontSize: 18,),),
                                        Text(res2.benefits,style: TextStyle(fontSize: 18,),)
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        Container(height:15),
                                        Container()
                                      ]
                                  ),

                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // const Text("Repeat Mantra: ",style: TextStyle(fontSize: 18,),),
                          // Row(
                          //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //   children: [
                          //     OutlinedButton(
                          //         onPressed: (){
                          //           setState((){
                          //             mantraCounter = 1;
                          //           });
                          //         },
                          //         child: const Text("1")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: () async{
                          //           setState((){
                          //             mantraCounter = 27;
                          //           });
                          //         },
                          //         child: const Text("27")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: ()async{
                          //           setState((){
                          //             mantraCounter = 54;
                          //           });
                          //         },
                          //         child: const Text("54")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: () async{
                          //           setState((){
                          //             mantraCounter = 108;
                          //           });
                          //         },
                          //         child: const Text("108")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: () {
                          //           setState(() {
                          //             mantraCounter = 999;
                          //           });
                          //         },
                          //         child: const Text("Infinite")
                          //     ),
                          //   ],
                          // ),
                          // OutlinedButton(
                          //     onPressed: (){
                          //       setState(() {
                          //         mantraCounter=0;
                          //       });
                          //     }, child: const Text("Reset")
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
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
              ]
            ),
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

