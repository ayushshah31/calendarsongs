import 'dart:async';
import 'dart:io';
import 'dart:math';

// import 'package:audio_service/audio_service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:calendarsong/auth/auth.dart';
// import 'package:just_audio_background/just_audio_background.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Widgets/audioPlayerHandler.dart';
import '../Widgets/calendarHeader.dart';
import '../constants/common.dart';
import '../constants/routes.dart';
import '../data/FirebaseFetch.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({Key? key}) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class DataRequiredForBuild{
  List mantraData;
  List mantra;
  dynamic tithiData;
  DataRequiredForBuild({required this.mantraData, required this.tithiData, required this.mantra});
}

class _CustomCalendarState extends State<CustomCalendar> {

  CalendarFormat _calendarFormat = CalendarFormat.week;
  final kToday = DateTime.now();
  DateTime? kFirstDay;
  DateTime? kLastDay;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final intro = AudioPlayer();
  Duration? durationIntro;
  final finalMantra = AudioPlayer();
  Duration? durationMantra;
  late PageController _pageController;

  bool playing = false;
  bool loading = true;
  List mantra = [];
  List mantraData = [];
  dynamic tithiData = [];
  bool introPlay = true;

  late Future<DataRequiredForBuild> _dataRequiredForBuild;
  Future<DataRequiredForBuild> _fetchData() async {
    final _firebaseFetch = FirebaseFetch();
    mantra = await _firebaseFetch.getMantra();
    mantraData = await _firebaseFetch.getMantraData();
    tithiData = await _firebaseFetch.getTithiData();
    // print("Mantra rec: $mantra");
    // print("MantraData rec: $mantraData");
    // print("Tithi rec: $tithiData");
    _downloadMantra("mantra");
    return DataRequiredForBuild(
        mantra: mantra,
        mantraData: mantraData,
        tithiData: tithiData
    );
  }

  late DateTime tithi;

  int getTithiDate(DateTime date){
    DateFormat formatter = DateFormat("yyyy-MM-dd");
    String temp = formatter.format(date);
    int tithiDate = tithiData[temp]["Tithi"];
    // print("Tithi is: $tithiDate");
    if (tithiDate>15 && tithiDate!=30){
      return tithiDate-15;
    }
    return tithiDate;
  }

  Object getTithiMantraData(int currTithi) {
    Object ans = {};
    for(int i=0; i<mantraData.length;i++){
      if(mantraData[i]["Tithi"]==currTithi){
        // print(mantraData[i]);
        ans = mantraData[i];
        break;
      }
    }
    return ans;
  }

  bool _downloading = true;
  late TargetPlatform? platform;
  bool isMantraDown = false;
  late bool _permissionReady;
  int mantraCounter = 0;

  @override
  void initState() {
    super.initState();
    kFirstDay = DateTime(2023,7,15);
    kLastDay = DateTime(kToday.year, 12, 3);
    _dataRequiredForBuild = _fetchData();
    if (Platform.isAndroid) {
      platform = TargetPlatform.android;
    } else {
      platform = TargetPlatform.iOS;
    }

    checkPermission();
    // init();
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
      String check = "$_localPath${Platform.pathSeparator}${mantraData[0]["Intro Sound File"]}";
      // print("Mantra there");
      final filePath = File(check);
      // print("FilePath: $filePath");
      final fileExists = await filePath.exists();
      if(fileExists){
        setState(() {
          isMantraDown = true;
          _downloading = false;
        });
        var res = getTithiDate(_selectedDay!);
        if(res !=30){
          setAudioPlayer(res-1);
        } else {
          setAudioPlayer(15);
        }
      } else {
        await download();
      }
    }
  }

  Future<void> download() async{
    setState(() {
      _downloading = true;
    });
    // print("Downloading");
    try {
      for(int i=0; i<mantraData.length; i++){
        await Dio().download(mantraData[i]["introLink"], "$_localPath${Platform.pathSeparator}${mantraData[i]["Intro Sound File"]}");
        await Dio().download(mantraData[i]["mantraLink"], "$_localPath${Platform.pathSeparator}${mantraData[i]["Mantra Sound file"]}");
      }
      // await Dio().download(mantra[0]['link'],
      //     "$_localPath/0.mp3");
      // print("Download Completed.");
      String check = "$_localPath${Platform.pathSeparator}${mantraData[0]["Intro Sound File"]}";
      // final filePath = File(check);
      // print("FilePathDownCheck: $filePath");
      setState(() {
        isMantraDown = true;
        _downloading = false;
      });
      var res = getTithiDate(_selectedDay!);
      if(res !=30){
        setAudioPlayer(res-1);
      } else {
        setAudioPlayer(15);
      }
    } catch (e) {
      print("Download Failed: $e");
      setState(() {
        _downloading = false;
      });
    }
  }

  Future<String?> _findLocalPath(String path) async {
    var directory = await getApplicationDocumentsDirectory();
    return '${directory.path}${Platform.pathSeparator}download/$path';
  }

  int audioTitle = 0;
  int image = 0;
  late String _localPath;

  Future<void> setAudioPlayer(int i) async{
    setState(() {
      loading = true;
    });
    String introFile = "$_localPath${Platform.pathSeparator}${mantraData[i]["Intro Sound File"]}";
    String mantraFile = "$_localPath${Platform.pathSeparator}${mantraData[i]["Mantra Sound file"]}";
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: [
        AudioSource.file(
            introFile,
            tag: MediaItem(
                id: "Intra $i",
                title: mantraData[i]["Intra Sound File"])
        ),
        AudioSource.file(
            mantraFile,
            tag: MediaItem(
                id: "Mantra $i",
                title: mantraData[i]["Mantra Sound file"]
            )
        )],
    );

    await intro.setAudioSource(playlist,initialIndex: 0,initialPosition: Duration.zero);
    await intro.stop();
    setState(() {
      durationIntro = intro.duration;
      loading = false;
    });
  }

  void changeReplayCount(){
    setState(() {
      mantraCounter -= 1;
    });
  }

  Future<void> signOutDialogBox()async {
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("SignOut"),
            content: const Text("Are you sure you want to SignOut?"),
            actions: [
              TextButton(
                  onPressed: ()=>Navigator.of(context).pop(),
                  child: const Text(
                    "cancel",
                    style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),
                  )
              ),
              TextButton(
                  onPressed: () async{
                    final auth = AuthService();
                    // print(FirebaseAuth.instance.currentUser);
                    // print(auth.user);
                    await auth.handleSignOut();
                    // print("Signout");
                    Navigator.pop(context);
                    Navigator.pushNamed(context, wrapperRoute);
                  },
                  child: const Text(
                    "Yes",
                    style: TextStyle(color: Colors.redAccent),
                  )
              )
            ],
          );
        }
    );
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xfff8dbc1),
        appBar: AppBar(
          title: const Text("TithiApp"),
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

                    case 4 :
                      signOutDialogBox();
                      break;
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
                  const PopupMenuItem(
                    value: 4,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("SignOut"),
                        SizedBox(width:10),
                        Icon(Icons.person,color: Colors.black,)
                      ],
                    ),
                  ),
                ]
            )
          ],
        ),
        body: Visibility(
          visible: !loading || !_downloading,
          replacement: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children : [
                SpinKitFoldingCube(
                  color: Colors.orange,
                ),
                SizedBox(height: 10),
                Text("Gathering Data")
              ]
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height + 500,
              child: Column(
                children: [
                  ValueListenableBuilder<DateTime>(
                    valueListenable: ValueNotifier(_focusedDay),
                    builder: (context, value, _) {
                      return CalendarHeader(
                        focusedDay: value,
                        // clearButtonVisible: canClearSelection,
                        onTodayButtonTap: () {
                          setState((){
                            _focusedDay = DateTime.now();
                            _selectedDay = DateTime.now();
                          });
                        },
                        onLeftArrowTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        onRightArrowTap: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        onClearButtonTap: () {},
                        clearButtonVisible: false,
                      );
                    },
                  ),
                  TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: kFirstDay!,
                      lastDay: kLastDay!,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                      ),
                      headerVisible: false,
                      daysOfWeekHeight: 20,
                      availableGestures: AvailableGestures.none,
                      calendarStyle: const CalendarStyle(
                        canMarkersOverflow: false,
                        isTodayHighlighted: true,
                        cellAlignment: Alignment.center,
                        // cellPadding: EdgeInsets.all(10),
                      ),
                      onCalendarCreated: (controller)=>_pageController=controller,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            mantraCounter = 0;
                          });
                          var res = getTithiDate(_selectedDay!);
                          // print("ResDateChange: $res");
                          if(res !=30){
                            setAudioPlayer(res-1);
                          } else {
                            setAudioPlayer(15);
                          }
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      }
                  ),

                  Expanded(
                      flex: 20,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.all(20),
                                child: FutureBuilder(
                                    future: _dataRequiredForBuild,
                                    builder: (context,snapshot){
                                      if(snapshot.hasData){
                                        var res = getTithiDate(_selectedDay!);
                                        dynamic res2 = getTithiMantraData(res);
                                        // print("Tithi curresponding mantra data: $res2");
                                        return Column(
                                          children: [
                                            Table(
                                              textBaseline: TextBaseline.ideographic,
                                              defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                                              columnWidths: const {
                                                0: IntrinsicColumnWidth(flex: 2),
                                                1: FlexColumnWidth(4)
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
                                                      Text(
                                                        res==15||res==30?"${res2["Intro Sound File"].toString().split(" ")[0]}":"${res2["Intro Sound File"].toString().split(" ")[1]}",
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w900,
                                                            color: const Color(0xFFA47500)
                                                        ),
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
                                                      const Text(
                                                          "Mantra: "
                                                      ),
                                                      Text(
                                                        res2["Mantra English"],
                                                        overflow: TextOverflow.visible,
                                                      ),
                                                    ]
                                                ),
                                                TableRow(
                                                    children: [
                                                      Container(height:10),
                                                      Container()
                                                    ]
                                                ),
                                                TableRow(
                                                    children: [
                                                      Container(),
                                                      Text(res2["Number of Repetitions"])
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
                                                      Text(res2["Procedure"])
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
                                                      Text(res2["Benefit"])
                                                    ]
                                                ),
                                                TableRow(
                                                    children: [
                                                      Container(height:15),
                                                      Container()
                                                    ]
                                                ),
                                                TableRow(
                                                    children:[
                                                      const Text("Mantra"),
                                                      Visibility(
                                                        visible: introPlay,
                                                        child: StreamBuilder<Duration>(
                                                            stream: intro.positionStream,
                                                            builder: (context, snapshot) {
                                                              // print("pos:${player.position.inMilliseconds.toDouble()}");
                                                              // print("buf:${player.bufferedPosition.inMilliseconds.toDouble()}");
                                                              // print(loading);
                                                              return !loading? Row(
                                                                children: [
                                                                  Text("${intro.position.inMinutes}:${intro.position.inSeconds%60}"),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Slider(
                                                                        value: min(intro.position.inMilliseconds.toDouble(),intro.duration!.inMilliseconds.toDouble()),
                                                                        min: 0.0,
                                                                        divisions: intro.duration!.inMilliseconds.toInt(),
                                                                        max: intro.duration!.inMilliseconds.toDouble()+5,
                                                                        onChanged: (val){
                                                                          intro.seek(Duration(milliseconds: val.toInt()));
                                                                        }
                                                                    ),
                                                                  ),
                                                                  Text("${intro.duration!.inMinutes}:${intro.duration!.inSeconds%60}"),
                                                                ],
                                                              ): Container();
                                                            }
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                                TableRow(
                                                    children: [
                                                      StreamBuilder<PlayerState>(
                                                          stream: intro.playerStateStream,
                                                          builder: (context, snapshot) {
                                                            return Text(
                                                                mantraCounter<109?"Repeat: $mantraCounter":"Repeat: ∞"
                                                            );
                                                          }
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          IconButton(onPressed: ()=>intro.seek(Duration(milliseconds: max(intro.position.inMilliseconds - 5000,0))), icon: const Icon(Icons.replay_5,size: 35,)),
                                                          StreamBuilder<PlayerState>(
                                                            stream: intro.playerStateStream,
                                                            builder: (context, snapshot) {
                                                              final playerState = snapshot.data;
                                                              final processingState = playerState?.processingState;
                                                              final playing = playerState?.playing;
                                                              if (processingState == ProcessingState.loading ||
                                                                  processingState == ProcessingState.buffering) {
                                                                return Container(
                                                                  margin: const EdgeInsets.all(8.0),
                                                                  width: 30.0,
                                                                  height: 30.0,
                                                                  child: const CircularProgressIndicator(),
                                                                );
                                                              } else if (playing != true) {
                                                                return IconButton(
                                                                  icon: const Icon(Icons.play_arrow),
                                                                  iconSize: 40.0,
                                                                  onPressed: intro.play,
                                                                );
                                                              } else if (processingState != ProcessingState.completed) {
                                                                return IconButton(
                                                                  icon: const Icon(Icons.pause),
                                                                  iconSize: 40.0,
                                                                  onPressed: intro.pause,
                                                                );
                                                              } else if(mantraCounter>0){
                                                                intro.seek(Duration.zero);
                                                                // print("Counter $mantraCounter");
                                                                mantraCounter -= 1;
                                                                return const Icon(Icons.repeat);
                                                              }
                                                              else {
                                                                return IconButton(
                                                                  icon: const Icon(Icons.replay),
                                                                  iconSize: 40.0,
                                                                  onPressed: () {
                                                                    // print("introSeq: ${intro.sequenceState}");
                                                                    // print(intro.sequenceState!.sequence);
                                                                    intro.seekToPrevious();
                                                                    intro.seek(Duration.zero);
                                                                  },
                                                                );
                                                              }
                                                            },
                                                          ),
                                                          IconButton(onPressed: ()=>intro.seek(Duration(milliseconds: intro.position.inMilliseconds + 5000)), icon: const Icon(Icons.forward_5,size: 35,))
                                                        ],
                                                      ),
                                                    ]
                                                ),
                                                TableRow(
                                                    children: [
                                                      Container(height:10),
                                                      Container()
                                                    ]
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }
                                )
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text("Repeat Mantra: "),
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                    onPressed: (){
                                      setState((){
                                        mantraCounter = 1;
                                      });
                                    },
                                    child: const Text("1")
                                ),
                                const Spacer(flex: 1),
                                OutlinedButton(
                                    onPressed: (){
                                      setState((){
                                        mantraCounter = 27;
                                      });
                                    },
                                    child: const Text("27")
                                ),
                                const Spacer(flex: 1),
                                OutlinedButton(
                                    onPressed: (){
                                      setState((){
                                        mantraCounter = 54;
                                      });
                                    },
                                    child: const Text("54")
                                ),
                                const Spacer(flex: 1),
                                OutlinedButton(
                                    onPressed: (){
                                      setState((){
                                        mantraCounter = 108;
                                      });
                                    },
                                    child: const Text("108")
                                ),
                                const Spacer(flex: 1),
                                OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        mantraCounter = 999;
                                      });
                                    },
                                    child: const Text("Infinite")
                                ),
                              ],
                            ),
                            OutlinedButton(
                                onPressed: (){
                                  setState(() {
                                    mantraCounter=0;
                                  });
                                }, child: const Text("Reset")
                            ),
                            const Spacer(flex: 1)
                          ],
                        ),
                      )
                  ),
                  // StreamBuilder<bool>(
                  //   stream: _audioHandler.playbackState
                  //       .map((state) => state.playing)
                  //       .distinct(),
                  //   builder: (context, snapshot) {
                  //     final playing = snapshot.data ?? false;
                  //     return Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         IconButton(icon:const Icon(Icons.fast_rewind), onPressed: _audioHandler.rewind),
                  //         if (playing)
                  //           IconButton(icon: const Icon(Icons.pause), onPressed: _audioHandler.pause)
                  //         else
                  //           IconButton(icon: const Icon(Icons.play_arrow), onPressed:_audioHandler.play),
                  //         IconButton(icon: const Icon(Icons.stop), onPressed:_audioHandler.stop),
                  //         IconButton(icon: const Icon(Icons.fast_forward), onPressed:_audioHandler.fastForward),
                  //       ],
                  //     );
                  //   },
                  // )
                  // const Text("Output Devices: "),
                  // Text(
                  //   "current output:${_currentInput.name} ${_currentInput.port}",
                  // ),
                  // Divider(),
                  // Expanded(
                  //   child: ListView.builder(
                  //     itemBuilder: (_, index) {
                  //       AudioInput input = _availableInputs[index];
                  //       return Row(
                  //         children: <Widget>[
                  //           Expanded(child: Text("${input.name}")),
                  //           Expanded(child: Text("${input.port}")),
                  //         ],
                  //       );
                  //     },
                  //     itemCount: _availableInputs.length,
                  //   ),
                  // ),
                  // FloatingActionButton(
                  //   onPressed: () async {
                  //     bool res = false;
                  //     if (_currentInput.port == AudioPort.receiver) {
                  //       res = await FlutterAudioManagerPlus.changeToSpeaker();
                  //       print("change to speaker:$res");
                  //     } else {
                  //       res = await FlutterAudioManagerPlus.changeToReceiver();
                  //       print("change to receiver:$res");
                  //     }
                  //     await _getInput();
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}