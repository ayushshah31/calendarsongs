import 'dart:developer';
import 'dart:io';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:calendarsong/Screens/feedback.dart';
import 'package:calendarsong/Screens/home.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/FirebaseFetch.dart';

class BottomBarController extends StatefulWidget {
  @override
  State<BottomBarController> createState() => _BottomBarControllerState();
}

class _BottomBarControllerState extends State<BottomBarController> {
  int _selectedIndex = 1;

  List<Widget> pages = [
    FeedbackPage(),
    HomePage(),
  ];
  String shareMsg = "", shareTxt = "";
  PageController _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchShareMsg();
  }

  fetchShareMsg() async {
    dynamic data = await FirebaseFetch().fetchShareMsg();
    // print("Share data1: $data");
    // print(data.runtimeType);
    // print(data["message"].toString());
    setState(() {
      shareMsg = data['message'];
      if (Platform.isAndroid) {
        shareTxt = data['text'];
      } else {
        shareTxt = data['textIOS'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mantra Therapy"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      // body: pages[_selectedIndex],
      body: PageView(
        controller: _pageController,
        children: pages,
        allowImplicitScrolling: false,
        physics: NeverScrollableScrollPhysics(),
        // onPageChanged: (value) {
        //   setState(() {
        //     _selectedIndex = value;
        //   });
        // },
      ),
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(
          // iconSize: 32,
          barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.animated,
          // opacity: 0.3,
        ),
        backgroundColor: const Color(0xFFf3ae85),
        items: [
          BottomBarItem(
            icon: Icon(Icons.feedback),
            title: Text("Feedback"),
            selectedColor: Colors.redAccent,
            selectedIcon: Icon(Icons.home, color: Colors.redAccent),
          ),
          BottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.redAccent,
            selectedIcon: Icon(Icons.home, color: Colors.redAccent),
          ),
        ],
        elevation: 1,
        currentIndex: _selectedIndex,
        hasNotch: false,
        fabLocation: StylishBarFabLocation.end,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: Color(0xfff8dbc1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Color(0xff80571d)),
        ),
        onPressed: () {
          Share.share(shareTxt, subject: shareMsg);
        },
        child: Icon(Icons.share, color: Color(0xff80571d)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      // bottomNavigationBar: BottomNavigationBar(
      // selectedItemColor: Colors.white,
      // items: [
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.feedback),
      //     label: 'Feedback',
      //     // backgroundColor: Colors.green,
      //   ),
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.home),
      //     label: 'Home',
      //     // backgroundColor: Colors.red,
      //   ),
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.share),
      //     label: 'Share',
      //     // backgroundColor: Colors.blue,
      //   ),
      // ],
      // currentIndex: _selectedIndex,
      // onTap: (value) {
      //   if (value == 2) {
      //     print('Share');
      //     Share.share(shareTxt, subject: shareMsg);
      //     // fetchShareMsg();
      //   } else {
      //   setState(() {
      //     _selectedIndex = value;
      //     _pageController.jumpToPage(value);
      //   });
      // }
      // },
      // )
    );
  }
}
