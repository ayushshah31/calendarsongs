import 'dart:io';
import 'dart:math';

import 'package:calendarsong/model/mantraData.dart';
import 'package:calendarsong/providers/mantraDataProvider.dart';
import 'package:calendarsong/providers/tithiDataProvider.dart';
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

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    Duration current = const Duration();
    mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    tithiData = Provider.of<TithiViewModel>(context).tithiModel;
    double sliderMax = 1;
    bool maxSet = false;

    void setSelectedDay(DateTime selectedDayNew) async{
      // await pageManager.clearQueue();
      setState(() {
        selectedDay = selectedDayNew;
        // pageManager.removeAll();
        pageManager.remove();
        pageManager.remove();
        pageManager.add(selectedDayNew, "Intro");
        print("Should Change");
        introPlaying = true;
        pageManager.pause();
        pageManager.seek(Duration.zero);
        pageManager.repeatButtonNotifier.value = RepeatState.repeatSong;
        pageManager.repeatCounterNotifier.value = 0;
        pageManager.repeat();
      });
    }
    var res = getTithiDate(selectedDay, tithiData);
    MantraModel res2 = getTithiMantraData(res);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("HomePage"),
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
                        Share.share('check out my website https://example.com', subject: 'Look what I made!');
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
          body: SizedBox(
            // padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeCalendarState(
                    setPageController: setPageController,
                    pageController: pageController,
                    selectedDay: selectedDay,
                    setSelectedDay: setSelectedDay,
                    focusedDay: focusedDay,
                    setFocusedDay: setFocusedDay,
                    mantraCounter: mantraCounter,
                    setMantraCounter: setMantraCount,
                    // pageController: pageControllerCal,
                    // getTithiDate: getTithiDate,
                    // setAudioPlayer: setAudioPlayer
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 20,
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
                                  TableRow(
                                      children: [
                                        const Text(
                                          "Tithi: ",
                                          style: TextStyle(
                                              fontSize: 20
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            res==15||res==30?res2.introSoundFile.toString().split(" ")[0]:res2.introSoundFile.toString().split(" ")[1],
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFA47500)
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        Container(height:5),
                                        Container()
                                      ]
                                  ),
                                  TableRow(
                                    children: [
                                      Container(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                              onPressed: (){
                                                DateTime newDay;
                                                newDay = selectedDay.subtract(const Duration(days: 1));
                                                print(newDay);
                                                setSelectedDay(newDay);
                                                setFocusedDay(newDay);
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
                                                DateTime newDay;
                                                newDay = selectedDay.add(const Duration(days: 1));
                                                print(newDay);
                                                setSelectedDay(newDay);
                                                setFocusedDay(newDay);
                                              },
                                              child: const Text("Next Tithi >")
                                          )
                                        ],
                                      )
                                    ]
                                  ),
                                  TableRow(
                                    children: [
                                      Container(height: 10),
                                      Container()
                                    ]
                                  ),
                                  TableRow(
                                      children: [
                                        const Text(
                                            "Mantra: "
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              res2.mantraEnglish,
                                              overflow: TextOverflow.visible,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              res2.mantraHindi,
                                              overflow: TextOverflow.visible,
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
                                        Text(res2.noOfRep)
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
                                        const Text("Procedure: "),
                                        Text(res2.procedure)
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
                                        const Text("Benefit: "),
                                        Text(res2.benefits)
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
                                      const Text("Mantra"),
                                      Container(
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
                                            // return ProgressBar(
                                            //   progress: value.current,
                                            //   buffered: value.buffered,
                                            //   total: value.total,
                                            //   onSeek: pageManager.seek,
                                            //   thumbCanPaintOutsideBar: true,
                                            //   barHeight: 5,
                                            //   barCapShape: BarCapShape.round,
                                            //   baseBarColor: Colors.white,
                                            // ) ;
                                            return Row(
                                              children: [
                                                Text("${value.current.inMinutes}:${value.current.inSeconds%60}"),
                                                Expanded(
                                                  flex: 4,
                                                  child: Slider(
                                                      value: min(value.current.inMilliseconds.toDouble(),max(value.total.inMilliseconds.toDouble(),sliderMax)),
                                                      min: 0.0,
                                                      divisions: max(sliderMax.toInt()+1,value.total.inMilliseconds+1),
                                                      max: max(sliderMax.toInt()+10,value.total.inMilliseconds+10),
                                                      onChanged: (val){
                                                        pageManager.seek(Duration(milliseconds: val.toInt()));
                                                      }
                                                  ),
                                                ),
                                                Text("${max(sliderMax~/60000,value.total.inMilliseconds~/60000)}:${max(sliderMax~/1000,value.total.inMilliseconds~/1000)}"),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ]
                                  ),
                                  TableRow(
                                    children: [
                                      Container(),
                                    // ValueListenableBuilder<int>(
                                    //     valueListenable: pageManager.repeatCounterNotifier,
                                    //     builder: (_, value, __) {
                                    //       // mantraCounter--;
                                    //       print("value: $value");
                                    //       return !(mantraCounter>110)?Text("Repeat: $value"):const Text("Repeat: ∞");
                                    //     }
                                    //   ),
                                      Row(
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
                                                // case RepeatState.repeatPlaylist:
                                                //   icon = const Icon(Icons.repeat);
                                                //   break;
                                              }
                                              return IconButton(
                                                icon: icon,
                                                onPressed: ()=>pageManager.repeat(),
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
                                                  return IconButton(
                                                    icon: const Icon(Icons.pause),
                                                    iconSize: 32.0,
                                                    onPressed: pageManager.pause,
                                                  );
                                                case ButtonState.finished:
                                                  if(introPlaying){
                                                    pageManager.remove();
                                                    pageManager.add(selectedDay,"mantra");
                                                    introPlaying = false;
                                                    pageManager.pause;
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
                                    ]
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // const Text("Repeat Mantra: "),
                          // Row(
                          //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //   children: [
                          //     OutlinedButton(
                          //         onPressed: (){
                          //           // pageManager.removeAll();
                          //           pageManager.clearQueue();
                          //           setState((){
                          //             mantraCounter = 1;
                          //             pageManager.add(selectedDay, "mantra");
                          //             // pageManager.play();
                          //           });
                          //         },
                          //         child: const Text("1")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: () async{
                          //           // pageManager.removeAll();
                          //           // pageManager.clearQueue();
                          //           pageManager.repeatCounterNotifier.value = 10;
                          //           pageManager.seek(Duration.zero);
                          //           pageManager.pause();
                          //           // pageManager.repeatButtonNotifier.value = RepeatState.repeatSong;
                          //           pageManager.onRepeatPlay();
                          //           // pageManager.repeat();
                          //           setState((){
                          //             mantraCounter = 10;
                          //             // pageManager.add(selectedDay, "mantra");
                          //             // pageManager.play();
                          //           });
                          //
                          //           // await pageManager.addCount(selectedDay, 5);
                          //         },
                          //         child: const Text("10")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: ()async{
                          //           // pageManager.removeAll();
                          //           pageManager.clearQueue();
                          //           setState((){
                          //             mantraCounter = 54;
                          //             // pageManager.play();
                          //           });
                          //           await pageManager.addCount(selectedDay, 54);
                          //         },
                          //         child: const Text("54")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: () async{
                          //           // pageManager.removeAll();
                          //           pageManager.clearQueue();
                          //           setState((){
                          //             mantraCounter = 108;
                          //             // pageManager.play();
                          //           });
                          //           await pageManager.addCount(selectedDay, 108);
                          //         },
                          //         child: const Text("108")
                          //     ),
                          //     const Spacer(flex: 1),
                          //     OutlinedButton(
                          //         onPressed: () {
                          //           // pageManager.removeAll();
                          //           setState(() {
                          //             mantraCounter = 999;
                          //             // pageManager.repeatButtonNotifier = RepeatState.repeatSong;
                          //             pageManager.repeat();
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
                // const SizedBox(height: 20),
                // SizedBox(
                //   height: 100,
                //   child: ValueListenableBuilder<List<String>>(
                //     valueListenable: pageManager.playlistNotifier,
                //     builder: (context, playlistTitles, _) {
                //       return ListView.builder(
                //         itemCount: playlistTitles.length,
                //         itemBuilder: (context, index) {
                //           return ListTile(
                //             title: Text(playlistTitles[index]),
                //           );
                //         },
                //       );
                //     },
                //   ),
                // ),
                // ValueListenableBuilder<String>(
                //   valueListenable: pageManager.currentSongTitleNotifier,
                //   builder: (_, title, __) {
                //     return Padding(
                //       padding: const EdgeInsets.only(top: 8.0),
                //       child: Text(title, style: const TextStyle(fontSize: 20)),
                //     );
                //   },
                // ),
                // const SizedBox(height: 20),

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

