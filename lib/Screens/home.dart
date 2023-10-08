import 'dart:math';

import 'package:calendarsong/model/mantraData.dart';
import 'package:calendarsong/providers/mantraDataProvider.dart';
import 'package:calendarsong/providers/tithiDataProvider.dart';
import 'package:calendarsong/providers/userRepeatData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';
import '../constants/common.dart';

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

  String _platformVersion = 'Unknown';

  bool loadSliderMax = false;
  double sliderMax = 1;
  int repeatMantraMode = 1;

  @override
  void initState() {
    print("In INIT");
    super.initState();
    getIt<PageManager>().init();
    initPlatformState();
    AdvancedInAppReview()
        .setMinDaysBeforeRemind(10)
        .setMinDaysAfterInstall(2)
        .setMinLaunchTimes(2)
        .setMinSecondsBeforeShowDialog(30)
        .monitor();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AdvancedInAppReview.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
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
    DateFormat formatter = DateFormat("yyyy-MM-dd");
    String temp = formatter.format(DateTime.now());
    currTithi = tithiData[temp]["Tithi"];
  }

  late TargetPlatform? platform;
  bool isMantraDown = false;

  List<MantraModel> mantraData = [];

  int res = -1;
  MantraModel res2 = MantraModel();
  late int currTithi;

  MantraModel getTithiMantraData(int currTithi1) {
    MantraModel ans = MantraModel();
    for (int i = 0; i < mantraData.length; i++) {
      if (mantraData[i].tithi == currTithi1) {
        // print(mantraData[i]);
        ans = mantraData[i];
        break;
      }
    }
    return ans;
  }

  List repeatList = [1, 27, 54, 108, 'Infinite'];
  int? _selected = 0;

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

  int? globalMantraMode = 1;
  final ScrollController _scrollController = ScrollController();

  int setSelected() {
    if (globalMantraMode == null) {
      return 0;
    } else if (globalMantraMode == 999) {
      return 4;
    } else {
      return repeatList.indexOf(globalMantraMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    Duration current = const Duration();
    mantraData = Provider.of<MantraViewModel>(context).mantraModel;
    tithiData = Provider.of<TithiViewModel>(context).tithiModel;
    globalMantraMode = Provider.of<UserRepeatViewModel>(context).mantraRepeatMode;

    if (globalMantraMode != null && globalMantraMode != repeatMantraMode) {
      repeatMantraMode = globalMantraMode!;
    }
    _selected = setSelected();

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
        // mantraCounter = 0;
        loadSliderMax = false;
        sliderMax = 1;
      });
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xfff8dbc1),
        body: Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          border: Border.all(color: Color(0xff80571d), width: 2),
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
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      currTithi = currTithi - 1;
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
                                        backgroundColor:
                                            MaterialStateProperty.all(Colors.orangeAccent),
                                        foregroundColor: MaterialStateProperty.all(Colors.white)),
                                    child: const Text("< Prev Tithi")),
                                OutlinedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(Colors.orangeAccent),
                                        foregroundColor: MaterialStateProperty.all(Colors.white)),
                                    onPressed: () {
                                      currTithi += 1;
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
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 30, 0),
                  child: ValueListenableBuilder<ProgressBarState>(
                    valueListenable: pageManager.progressNotifier,
                    builder: (_, value, __) {
                      current = value.current;
                      return Row(
                        children: [
                          Text("00:${value.current.inSeconds % 60}"),
                          Expanded(
                            flex: 4,
                            child: Slider(
                                value: min(value.current.inMilliseconds.toDouble(),
                                    max(value.total.inMilliseconds.toDouble(), sliderMax)),
                                min: 0.0,
                                divisions:
                                    max(sliderMax.toInt() + 1, value.total.inMilliseconds + 1),
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
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
                            }
                            return IconButton(
                              icon: icon,
                              onPressed: () => pageManager.repeat(),
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
                                var total = pageManager.progressNotifier.value.total.inMilliseconds;
                                if (loadSliderMax || sliderMax < total) {
                                  print(
                                      "Total: ${pageManager.progressNotifier.value.total.inMilliseconds}");
                                  sliderMax = pageManager
                                      .progressNotifier.value.total.inMilliseconds
                                      .toDouble();
                                  print("SliderMax: $sliderMax");
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
                                  // pageManager.remove();
                                  // pageManager.add(res, "mantra");
                                  // print("Trial counter: $globalMantraMode");
                                  // print("counter intro: $repeatMantraMode");
                                  // print("Trial counter: $globalMantraMode");
                                  if (repeatMantraMode > 108) {
                                    pageManager.add(res, "mantra");
                                    pageManager.repeat();
                                    pageManager.pause();
                                    // pageManager.play();
                                  } else {
                                    pageManager.repeatMantraCount(repeatMantraMode, res);
                                  }
                                  print("Load mantra");
                                  print(
                                      "Total load: ${pageManager.progressNotifier.value.total.inMilliseconds}");
                                  introPlaying = false;
                                  pageManager.pause();
                                  // pageManager.play();
                                  loadSliderMax = true;
                                  // pageManager.duration();
                                }
                                return IconButton(
                                  icon: const Icon(Icons.replay),
                                  iconSize: 32.0,
                                  onPressed: () {
                                    print("finis");
                                    // pageManager.seek(Duration.zero);
                                    print("counter val: ${repeatMantraMode}");
                                    pageManager.repeatMantraCount(repeatMantraMode, res);
                                    pageManager.pause();
                                    pageManager.play();
                                  },
                                );
                            }
                          },
                        ),
                        IconButton(
                            onPressed: () => pageManager.next5(current),
                            icon: const Icon(Icons.forward_5))
                      ],
                    ),
                  ),
                ]),
                // const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.spaceBetween,
                      spacing: 2,
                      children: [
                        Text(
                          "Repeat Mantra:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        ...List<Widget>.generate(5, (int index) {
                          return ChoiceChip(
                            label: Text("${repeatList[index]}"),
                            labelPadding: EdgeInsets.all(0),
                            // padding: EdgeInsets.symmetric(horizontal: 8),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            selectedColor: Color(0xff80571d),
                            backgroundColor: Color(0xfff8dbc1),
                            labelStyle: TextStyle(
                              color: _selected == index ? Color(0xfff8dbc1) : Color(0xff80571d),
                            ),
                            side: BorderSide(color: Color(0xff80571d)),
                            selected: _selected == index,
                            showCheckmark: false,
                            onSelected: (sel) {
                              setState(() {
                                _selected = sel ? index : 0;
                                var med = repeatList[_selected!];
                                med = (med == 'Infinite') ? 999 : med;
                                if (med > 108) {
                                  pageManager.repeat();
                                } else {
                                  pageManager.repeatButtonNotifier.value = RepeatState.repeatSong;
                                  pageManager.repeat();
                                  // mantraCounter = med;
                                  setState(() {
                                    repeatMantraMode = med;
                                  });
                                  pageManager.repeatMantraCount(med, res);
                                  pageManager.pause();
                                  // pageManager.play();
                                }
                                Provider.of<UserRepeatViewModel>(context, listen: false)
                                    .changeMode(med);
                                // print("Trial change: $globalMantraMode");
                                // print("counter change: $repeatMantraMode");
                              });
                            },
                          );
                        }).toList()
                      ]),
                ),
                const SizedBox(height: 10),
                Flexible(
                  fit: FlexFit.tight,
                  child: VsScrollbar(
                    isAlwaysShown: true,
                    controller: _scrollController,
                    style: VsScrollbarStyle(
                      hoverThickness: 10.0,
                      radius: Radius.circular(10),
                      thickness: 5.0,
                      color: Color(0xff80571d),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        controller: _scrollController,
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
                                child:
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            // Text("RepeatModeState: $trialMantraMode"),
                            // OutlinedButton(
                            //     onPressed: () {
                            //       Provider.of<UserRepeatViewModel>(context, listen: false)
                            //           .changeMode(trialMantraMode + 5);
                            //     },
                            //     child: Text("Change Count to +5"))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
