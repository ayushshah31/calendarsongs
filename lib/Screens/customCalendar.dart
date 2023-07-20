// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:audio_service/audio_service.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:calendarsong/model/mantraData.dart';
// import 'package:calendarsong/model/tithiData.dart';
// import 'package:calendarsong/providers/mantraDataProvider.dart';
// import 'package:calendarsong/providers/tithiDataProvider.dart';
// // import 'package:calendarsong/auth/auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:rxdart/rxdart.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:table_calendar/table_calendar.dart';
// import '../Widgets/audioPlayerHandler.dart';
// import '../Widgets/calendarHeader.dart';
// import '../Widgets/homeCalendar.dart';
// import '../auth/auth.dart';
// import '../constants/common.dart';
// import '../constants/routes.dart';
// import '../data/FirebaseFetch.dart';
// import 'package:intl/intl.dart';
//
// class CustomCalendar extends StatefulWidget {
//   CustomCalendar({Key? key}) : super(key: key);
//
//   // final AudioHandler audioHandler;
//
//   @override
//   State<CustomCalendar> createState() => _CustomCalendarState();
// }
//
// class DataRequiredForBuild{
//   List mantraData;
//   List mantra;
//   dynamic tithiData;
//   DataRequiredForBuild({required this.mantraData, required this.tithiData, required this.mantra});
// }
//
// class _CustomCalendarState extends State<CustomCalendar> {
//
//
//   DateTime focusedDay = DateTime.now();
//   DateTime selectedDay = DateTime.now();
//   final intro = AudioPlayer();
//   Duration? durationIntro;
//   final finalMantra = AudioPlayer();
//   Duration? durationMantra;
//
//   bool playing = false;
//   bool loading = true;
//   List mantra = [];
//   List mantraData = [];
//   dynamic tithiData = [];
//   bool introPlay = true;
//
//   late Future<DataRequiredForBuild> _dataRequiredForBuild;
//   Future<DataRequiredForBuild> _fetchData() async {
//     final _firebaseFetch = FirebaseFetch();
//     mantra = await _firebaseFetch.getMantra();
//     mantraData = await _firebaseFetch.getMantraData();
//     tithiData = await _firebaseFetch.getTithiData();
//     // print("Mantra rec: $mantra");
//     // print("MantraData rec: $mantraData");
//     // print("Tithi rec: $tithiData");
//     _downloadMantra("mantra");
//     return DataRequiredForBuild(
//       mantra: mantra,
//       mantraData: mantraData,
//       tithiData: tithiData
//     );
//   }
//
//   late DateTime tithi;
//
//   bool _downloading = true;
//   late TargetPlatform? platform;
//   bool isMantraDown = false;
//   late bool _permissionReady;
//   int mantraCounter = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _dataRequiredForBuild = _fetchData();
//     if (Platform.isAndroid) {
//       platform = TargetPlatform.android;
//     } else {
//       platform = TargetPlatform.iOS;
//     }
//
//     checkPermission();
//     // init();
//   }
//
//   Future<String?> _findLocalPath(String path) async {
//     var directory = await getApplicationDocumentsDirectory();
//     return '${directory.path}${Platform.pathSeparator}download/$path';
//   }
//
//   int audioTitle = 0;
//   int image = 0;
//   late String _localPath;
//
//   Future<void> setAudioPlayer(int i) async{
//     setState(() {
//       loading = true;
//     });
//     String introFile = "$_localPath${Platform.pathSeparator}${mantraData[i]["Intro Sound File"]}";
//     String mantraFile = "$_localPath${Platform.pathSeparator}${mantraData[i]["Mantra Sound file"]}";
//     final session = await AudioSession.instance;
//     print(mantraData);
//     print(mantraData[i]["Intro Sound File"]);
//     await session.configure(const AudioSessionConfiguration.speech());
//     final playlist = ConcatenatingAudioSource(
//       useLazyPreparation: true,
//       children: [
//         AudioSource.file(
//           introFile,
//           tag: MediaItem(
//               id: "Intra $i",
//               title: mantraData[i]["Intro Sound File"])
//         ),
//         AudioSource.file(
//             mantraFile,
//           tag: MediaItem(
//               id: "Mantra $i",
//               title: mantraData[i]["Mantra Sound file"]
//           )
//         )],
//     );
//
//     await intro.setAudioSource(playlist,initialIndex: 0,initialPosition: Duration.zero);
//     await intro.stop();
//     setState(() {
//       durationIntro = intro.duration;
//       loading = false;
//     });
//   }
//
//   void changeReplayCount(){
//     setState(() {
//       mantraCounter -= 1;
//     });
//   }
//
//   // Stream<MediaState> get _mediaStateStream =>
//   //     Rx.combineLatest2<MediaItem?, Duration, MediaState>(
//   //         widget.audioHandler.mediaItem,
//   //         AudioService.position,
//   //             (mediaItem, position) => MediaState(mediaItem, position));
//
//   IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
//     icon: Icon(iconData),
//     iconSize: 64.0,
//     onPressed: onPressed,
//   );
//
//   Future<void> signOutDialogBox()async {
//     return showDialog(
//         context: context,
//         builder: (context){
//           return AlertDialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             title: const Text("SignOut"),
//             content: const Text("Are you sure you want to SignOut?"),
//             actions: [
//               TextButton(
//                   onPressed: ()=>Navigator.of(context).pop(),
//                   child: const Text(
//                     "cancel",
//                     style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),
//                   )
//               ),
//               TextButton(
//                   onPressed: () async{
//                     final auth = AuthService();
//                     // print(FirebaseAuth.instance.currentUser);
//                     // print(auth.user);
//                     await auth.handleSignOut();
//                     // print("Signout");
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, wrapperRoute);
//                   },
//                   child: const Text(
//                     "Yes",
//                     style: TextStyle(color: Colors.redAccent),
//                   )
//               )
//             ],
//           );
//         }
//     );
//   }
//
//   void setSelectedDay(DateTime selectedDayNew){
//     setState(() {
//       selectedDay = selectedDayNew;
//     });
//   }
//
//   void setFocusedDay(DateTime focusedDayNew){
//     setState(() {
//       focusedDay = focusedDayNew;
//     });
//   }
//
//   void setMantraCount(int newCount){
//     setState(() {
//       mantraCounter = newCount;
//     });
//   }
//
//   late PageController pageController = PageController();
//
//   void setPageController(PageController controller){
//     // setState(() {
//       pageController = controller;
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<MantraModel> mantraModelPro = Provider.of<MantraViewModel>(context).mantraModel;
//     dynamic tithiDataPro = Provider.of<TithiViewModel>(context).tithiModel;
//     print("TithiModelPro in cc: $tithiDataPro");
//     print("MantraModelPro: $mantraModelPro");
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xfff8dbc1),
//         appBar: AppBar(
//           title: const Text("TithiApp"),
//           automaticallyImplyLeading: false,
//           actions: [
//             PopupMenuButton(
//                 icon: Image.asset("lib/assets/images/more.png",color: Colors.white,),
//                 position: PopupMenuPosition.under,
//                 onSelected: (value){
//                   switch(value){
//                     // case 0:
//                     //   Navigator.pushNamed(context, playlists);
//                     //   break;
//
//                     case 1:
//                       const snackBar = SnackBar(content: Text("Feature not available in your location"),duration: Duration(seconds: 3),);
//                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                       break;
//
//                     case 2:
//                       Navigator.pushNamed(context, feedback);
//                       break;
//
//                     case 3:
//                       Share.share('check out my website https://example.com', subject: 'Look what I made!');
//                       break;
//
//                     // case 4 :
//                     //   signOutDialogBox();
//                     //   break;
//                   }
//                 },
//                 itemBuilder: (context)=>[
//                   // const PopupMenuItem(
//                   //   value: 0,
//                   //   padding: EdgeInsets.symmetric(horizontal: 10),
//                   //   child: Row(
//                   //     mainAxisAlignment: MainAxisAlignment.center,
//                   //     children: [
//                   //       Text("Playlists"),
//                   //       SizedBox(width:10),
//                   //       Icon(Icons.playlist_add,color: Colors.black,)
//                   //     ],
//                   //   ),
//                   //   // onTap: ,
//                   // ),
//                   const PopupMenuItem(
//                     value: 1,
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text("Get Pro"),
//                         SizedBox(width:10),
//                         Icon(Icons.paid_rounded,color: Colors.black,)
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 2,
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text("Feedback"),
//                         SizedBox(width:10),
//                         Icon(Icons.mail,color: Colors.black,)
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                       value: 3,
//                       padding: EdgeInsets.symmetric(horizontal: 10),
//                       child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("Share"),
//                           SizedBox(width: 10),
//                           Icon(Icons.ios_share_outlined,color: Colors.black,),
//                         ]
//                       )
//                   ),
//                   // const PopupMenuItem(
//                   //   value: 4,
//                   //   padding: EdgeInsets.symmetric(horizontal: 10),
//                   //   child: Row(
//                   //     mainAxisAlignment: MainAxisAlignment.center,
//                   //     children: [
//                   //       Text("SignOut"),
//                   //       SizedBox(width:10),
//                   //       Icon(Icons.person,color: Colors.black,)
//                   //     ],
//                   //   ),
//                   // ),
//                 ]
//             )
//           ],
//         ),
//         body: Visibility(
//           visible: !loading || !_downloading,
//           replacement: const Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children : [
//               SpinKitFoldingCube(
//                 color: Colors.orange,
//               ),
//               SizedBox(height: 10),
//               Text("Gathering Data")
//             ]
//           ),
//           child: SingleChildScrollView(
//             child: SizedBox(
//               height: MediaQuery.of(context).size.height + 500,
//               child: Column(
//                 children: [
//                   HomeCalendarState(
//                       setPageController: setPageController,
//                       pageController: pageController,
//                       selectedDay: selectedDay,
//                       setSelectedDay: setSelectedDay,
//                       focusedDay: focusedDay,
//                       setFocusedDay: setFocusedDay,
//                       mantraCounter: mantraCounter,
//                       setMantraCounter: setMantraCount,
//                       // pageController: pageControllerCal,
//                       // getTithiDate: getTithiDate,
//                       // setAudioPlayer: setAudioPlayer
//                   ),
//
//                   Expanded(
//                     flex: 20,
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(20),
//                             child: FutureBuilder(
//                               future: _dataRequiredForBuild,
//                               builder: (context,snapshot){
//                                 if(snapshot.hasData){
//                                   var res = getTithiDate(selectedDay, tithiData);
//                                   dynamic res2 = getTithiMantraData(res);
//                                   return Column(
//                                     children: [
//                                       Table(
//                                         textBaseline: TextBaseline.ideographic,
//                                         defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
//                                         columnWidths: const {
//                                           0: IntrinsicColumnWidth(flex: 2),
//                                           1: FlexColumnWidth(4)
//                                         },
//                                         children: [
//                                           TableRow(
//                                             children: [
//                                               const Text(
//                                                 "Tithi: ",
//                                                 style: TextStyle(
//                                                     fontSize: 20
//                                                 ),
//                                               ),
//                                               Text(
//                                                 res==15||res==30?res2["Intro Sound File"].toString().split(" ")[0]:res2["Intro Sound File"].toString().split(" ")[1],
//                                                 style: const TextStyle(
//                                                     fontSize: 18,
//                                                     fontWeight: FontWeight.w900,
//                                                     color: Color(0xFFA47500)
//                                                 ),
//                                               ),
//                                             ]
//                                           ),
//                                           TableRow(
//                                               children: [
//                                                 Container(height:15),
//                                                 Container()
//                                               ]
//                                           ),
//                                           TableRow(
//                                             children: [
//                                               const Text(
//                                                   "Mantra: "
//                                               ),
//                                               Text(
//                                                 res2["Mantra English"],
//                                                 overflow: TextOverflow.visible,
//                                               ),
//                                             ]
//                                           ),
//                                           TableRow(
//                                               children: [
//                                                 Container(height:10),
//                                                 Container()
//                                               ]
//                                           ),
//                                           TableRow(
//                                             children: [
//                                               Container(),
//                                               Text(res2["Number of Repetitions"])
//                                             ]
//                                           ),
//                                           TableRow(
//                                               children: [
//                                                 Container(height:15),
//                                                 Container()
//                                               ]
//                                           ),
//                                           TableRow(
//                                             children: [
//                                               const Text("Procedure: "),
//                                               Text(res2["Procedure"])
//                                             ]
//                                           ),
//                                           TableRow(
//                                               children: [
//                                                 Container(height:15),
//                                                 Container()
//                                               ]
//                                           ),
//                                           TableRow(
//                                             children: [
//                                               const Text("Benefit: "),
//                                               Text(res2["Benefit"])
//                                             ]
//                                           ),
//                                           TableRow(
//                                               children: [
//                                                 Container(height:15),
//                                                 Container()
//                                               ]
//                                           ),
//                                           TableRow(
//                                             children:[
//                                               const Text("Mantra"),
//                                               Visibility(
//                                                 visible: introPlay,
//                                                 child: StreamBuilder<Duration>(
//                                                     stream: intro.positionStream,
//                                                     builder: (context, snapshot) {
//                                                       // print("pos:${player.position.inMilliseconds.toDouble()}");
//                                                       // print("buf:${player.bufferedPosition.inMilliseconds.toDouble()}");
//                                                       // print(loading);
//                                                       return !loading? Row(
//                                                         children: [
//                                                           Text("${intro.position.inMinutes}:${intro.position.inSeconds%60}"),
//                                                           Expanded(
//                                                             flex: 4,
//                                                             child: Slider(
//                                                                 value: min(intro.position.inMilliseconds.toDouble(),intro.duration!.inMilliseconds.toDouble()),
//                                                                 min: 0.0,
//                                                                 divisions: intro.duration!.inMilliseconds.toInt(),
//                                                                 max: intro.duration!.inMilliseconds.toDouble()+5,
//                                                                 onChanged: (val){
//                                                                   intro.seek(Duration(milliseconds: val.toInt()));
//                                                                 }
//                                                             ),
//                                                           ),
//                                                           Text("${intro.duration!.inMinutes}:${intro.duration!.inSeconds%60}"),
//                                                         ],
//                                                       ): Container();
//                                                     }
//                                                 ),
//                                               ),
//                                             ]
//                                           ),
//                                           TableRow(
//                                             children: [
//                                               StreamBuilder<PlayerState>(
//                                                   stream: intro.playerStateStream,
//                                                   builder: (context, snapshot) {
//                                                     return Text(
//                                                         mantraCounter<109?"Repeat: $mantraCounter":"Repeat: ∞"
//                                                       );
//                                                     }
//                                                   ),
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                 children: [
//                                                   IconButton(onPressed: ()=>intro.seek(Duration(milliseconds: max(intro.position.inMilliseconds - 5000,0))), icon: const Icon(Icons.replay_5,size: 35,)),
//                                                   StreamBuilder<PlayerState>(
//                                                     stream: intro.playerStateStream,
//                                                     builder: (context, snapshot) {
//                                                       final playerState = snapshot.data;
//                                                       final processingState = playerState?.processingState;
//                                                       final playing = playerState?.playing;
//                                                       if (processingState == ProcessingState.loading ||
//                                                           processingState == ProcessingState.buffering) {
//                                                         return Container(
//                                                           margin: const EdgeInsets.all(8.0),
//                                                           width: 30.0,
//                                                           height: 30.0,
//                                                           child: const CircularProgressIndicator(),
//                                                         );
//                                                       } else if (playing != true) {
//                                                         return IconButton(
//                                                           icon: const Icon(Icons.play_arrow),
//                                                           iconSize: 40.0,
//                                                           onPressed: intro.play,
//                                                         );
//                                                       } else if (processingState != ProcessingState.completed) {
//                                                         return IconButton(
//                                                           icon: const Icon(Icons.pause),
//                                                           iconSize: 40.0,
//                                                           onPressed: intro.pause,
//                                                         );
//                                                       } else if(mantraCounter>0){
//                                                         intro.seek(Duration.zero);
//                                                         // print("Counter $mantraCounter");
//                                                         mantraCounter -= 1;
//                                                         return const Icon(Icons.repeat);
//                                                       }
//                                                       else {
//                                                         return IconButton(
//                                                           icon: const Icon(Icons.replay),
//                                                           iconSize: 40.0,
//                                                           onPressed: () {
//                                                             // print("introSeq: ${intro.sequenceState}");
//                                                             // print(intro.sequenceState!.sequence);
//                                                             intro.seekToPrevious();
//                                                             intro.seek(Duration.zero);
//                                                           },
//                                                         );
//                                                       }
//                                                     },
//                                                   ),
//                                                   IconButton(onPressed: ()=>intro.seek(Duration(milliseconds: intro.position.inMilliseconds + 5000)), icon: const Icon(Icons.forward_5,size: 35,))
//                                                 ],
//                                               ),
//                                             ]
//                                           ),
//                                           TableRow(
//                                               children: [
//                                                 Container(height:10),
//                                                 Container()
//                                               ]
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   );
//                                 } else {
//                                   return Container();
//                                 }
//                               }
//                             )
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.all(10.0),
//                             child: Text("Repeat Mantra: "),
//                           ),
//                           Row(
//                             // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               OutlinedButton(
//                                   onPressed: (){
//                                     setState((){
//                                       mantraCounter = 1;
//                                     });
//                                   },
//                                   child: const Text("1")
//                               ),
//                               const Spacer(flex: 1),
//                               OutlinedButton(
//                                   onPressed: (){
//                                     setState((){
//                                       mantraCounter = 27;
//                                     });
//                                   },
//                                   child: const Text("27")
//                               ),
//                               const Spacer(flex: 1),
//                               OutlinedButton(
//                                   onPressed: (){
//                                     setState((){
//                                       mantraCounter = 54;
//                                     });
//                                   },
//                                   child: const Text("54")
//                               ),
//                               const Spacer(flex: 1),
//                               OutlinedButton(
//                                   onPressed: (){
//                                     setState((){
//                                       mantraCounter = 108;
//                                     });
//                                   },
//                                   child: const Text("108")
//                               ),
//                               const Spacer(flex: 1),
//                               OutlinedButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       mantraCounter = 999;
//                                     });
//                                   },
//                                   child: const Text("Infinite")
//                               ),
//                             ],
//                           ),
//                           OutlinedButton(
//                               onPressed: (){
//                                 setState(() {
//                                   mantraCounter=0;
//                                 });
//                               }, child: const Text("Reset")
//                           ),
//                           const Spacer(flex: 1)
//                         ],
//                       ),
//                     )
//                   ),
//                   // StreamBuilder<MediaItem?>(
//                   //   stream: widget.audioHandler.mediaItem,
//                   //   builder: (context, snapshot) {
//                   //     final mediaItem = snapshot.data;
//                   //     return Text(mediaItem?.title ?? '');
//                   //   },
//                   // ),
//                   // //Play,Pause,Stop button
//                   // StreamBuilder<bool>(
//                   //   stream: widget.audioHandler.playbackState
//                   //       .map((state) => state.playing)
//                   //       .distinct(),
//                   //   builder: (context, snapshot) {
//                   //     final playing = snapshot.data ?? false;
//                   //     return Row(
//                   //       mainAxisAlignment: MainAxisAlignment.center,
//                   //       children: [
//                   //         _button(Icons.fast_rewind, widget.audioHandler.rewind),
//                   //         if (playing)
//                   //           _button(Icons.pause, widget.audioHandler.pause)
//                   //         else
//                   //           _button(Icons.play_arrow, widget.audioHandler.play),
//                   //         _button(Icons.stop, widget.audioHandler.stop),
//                   //         _button(Icons.fast_forward, widget.audioHandler.fastForward),
//                   //       ],
//                   //     );
//                   //   },
//                   // ),
//                   // StreamBuilder<bool>(
//                   //   stream: widget.audioHandler.playbackState
//                   //       .map((state) => state.playing)
//                   //       .distinct(),
//                   //   builder: (context, snapshot) {
//                   //     final playing = snapshot.data ?? false;
//                   //     return Row(
//                   //       mainAxisAlignment: MainAxisAlignment.center,
//                   //       children: [
//                   //         _button(Icons.fast_rewind, widget.audioHandler.rewind),
//                   //         if (playing)
//                   //           _button(Icons.pause, widget.audioHandler.pause)
//                   //         else
//                   //           _button(Icons.play_arrow, widget.audioHandler.play),
//                   //         _button(Icons.stop, widget.audioHandler.stop),
//                   //         _button(Icons.fast_forward, widget.audioHandler.fastForward),
//                   //       ],
//                   //     );
//                   //   },
//                   // ),
//                   // // A seek bar.
//                   // StreamBuilder<MediaState>(
//                   //   stream: _mediaStateStream,
//                   //   builder: (context, snapshot) {
//                   //     final mediaState = snapshot.data;
//                   //     return SeekBar(
//                   //       duration: mediaState?.mediaItem?.duration ?? Duration.zero,
//                   //       position: mediaState?.position ?? Duration.zero,
//                   //       onChangeEnd: (newPosition) {
//                   //         widget.audioHandler.seek(newPosition);
//                   //       },
//                   //     );
//                   //   },
//                   // ),
//                   // StreamBuilder<AudioProcessingState>(
//                   //   stream: widget.audioHandler.playbackState
//                   //       .map((state) => state.processingState)
//                   //       .distinct(),
//                   //   builder: (context, snapshot) {
//                   //     final processingState =
//                   //         snapshot.data ?? AudioProcessingState.idle;
//                   //     return Text(
//                   //         "Processing state: ${describeEnum(processingState)}");
//                   //   },
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MediaState {
//   final MediaItem? mediaItem;
//   final Duration position;
//
//   MediaState(this.mediaItem, this.position);
// }
// /// An [AudioHandler] for playing a single item.
// class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
//   static final _item = MediaItem(
//     id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
//     album: "Science Friday",
//     title: "A Salute To Head-Scratching Science",
//     artist: "Science Friday and WNYC Studios",
//     duration: const Duration(milliseconds: 5739820),
//     artUri: Uri.parse(
//         'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
//   );
//
//   final _player = AudioPlayer();
//
//   /// Initialise our audio handler.
//   AudioPlayerHandler() {
//     // So that our clients (the Flutter UI and the system notification) know
//     // what state to display, here we set up our audio handler to broadcast all
//     // playback state changes as they happen via playbackState...
//     _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
//     // ... and also the current media item via mediaItem.
//     mediaItem.add(_item);
//
//     // Load the player.
//     _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
//   }
//
//   // In this simple example, we handle only 4 actions: play, pause, seek and
//   // stop. Any button press from the Flutter UI, notification, lock screen or
//   // headset will be routed through to these 4 methods so that you can handle
//   // your audio playback logic in one place.
//
//   @override
//   Future<void> play() => _player.play();
//
//   @override
//   Future<void> pause() => _player.pause();
//
//   @override
//   Future<void> seek(Duration position) => _player.seek(position);
//
//   @override
//   Future<void> stop() => _player.stop();
//
//   /// Transform a just_audio event into an audio_service state.
//   ///
//   /// This method is used from the constructor. Every event received from the
//   /// just_audio player will be transformed into an audio_service state so that
//   /// it can be broadcast to audio_service clients.
//   PlaybackState _transformEvent(PlaybackEvent event) {
//     return PlaybackState(
//       controls: [
//         MediaControl.rewind,
//         if (_player.playing) MediaControl.pause else MediaControl.play,
//         MediaControl.stop,
//         MediaControl.fastForward,
//       ],
//       systemActions: const {
//         MediaAction.seek,
//         MediaAction.seekForward,
//         MediaAction.seekBackward,
//       },
//       androidCompactActionIndices: const [0, 1, 3],
//       processingState: const {
//         ProcessingState.idle: AudioProcessingState.idle,
//         ProcessingState.loading: AudioProcessingState.loading,
//         ProcessingState.buffering: AudioProcessingState.buffering,
//         ProcessingState.ready: AudioProcessingState.ready,
//         ProcessingState.completed: AudioProcessingState.completed,
//       }[_player.processingState]!,
//       playing: _player.playing,
//       updatePosition: _player.position,
//       bufferedPosition: _player.bufferedPosition,
//       speed: _player.speed,
//       queueIndex: event.currentIndex,
//     );
//   }
// }