import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:calendarsong/Screens/feedback.dart';
import 'package:calendarsong/Screens/home.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/routes.dart';
import '../data/FirebaseFetch.dart';

class BottomBarController extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  BottomBarController({required this.analytics, required this.observer});
  @override
  State<BottomBarController> createState() => _BottomBarControllerState();
}

class _BottomBarControllerState extends State<BottomBarController> {
  int _selectedIndex = 3;

  // List<Widget> pages = [];
  String shareMsg = "", shareTxt = "";
  PageController _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    fetchShareMsg();
  }

  List<Widget> listPages(){
    return [
      FeedbackPage(),
      HomePage(),
    ];
  }

  fetchShareMsg() async {
    dynamic data = await FirebaseFetch().fetchShareMsg();
    shareMsg = data['message'];
    if (Platform.isAndroid) {
      shareTxt = data['text'];
    } else {
      shareTxt = data['textIOS'];
    }
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
      body: HomePage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFf3ae85),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              null,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              null,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              null,
            ),
            label: "",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, feedback);
          } else {}
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
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
