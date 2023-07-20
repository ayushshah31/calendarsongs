import 'package:calendarsong/providers/tithiDataProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/common.dart';
import 'calendarHeader.dart';


class HomeCalendarState extends StatelessWidget {
  HomeCalendarState({super.key, required this.selectedDay, required this.setSelectedDay, required this.focusedDay,
    required this.setFocusedDay,required this.mantraCounter,  required this.setMantraCounter, required this.pageController,
    required this.setPageController});
  // DateTime kToday = DateTime.now();
  DateTime kFirstDay = DateTime(2023,7,15);
  DateTime kLastDay = DateTime(2023, 12, 3);
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime selectedDay;
  DateTime focusedDay;
  int? mantraCounter;
  PageController pageController;
  // Function getTithiDate;
  // Function setAudioPlayer;
  Function setSelectedDay;
  Function setFocusedDay;
  Function setMantraCounter;
  Function setPageController;

  @override
  Widget build(BuildContext context) {
    // dynamic tithiData = Provider.of<TithiViewModel>(context).tithiModel;
    return Column(
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: ValueNotifier(focusedDay),
          builder: (context, value, _) {
            return CalendarHeader(
              focusedDay: value,
              // clearButtonVisible: canClearSelection,
              onTodayButtonTap: () {
                setFocusedDay(DateTime.now());
                setSelectedDay(DateTime.now());
                // focusedDay = DateTime.now();
                // selectedDay = DateTime.now();
               // TODO: call setstate in home from here
              },
              onLeftArrowTap: () {
                print(pageController);
                pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              onRightArrowTap: () {
                pageController.nextPage(
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
            focusedDay: focusedDay,
            firstDay: kFirstDay,
            lastDay: kLastDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),
            headerVisible: false,
            daysOfWeekHeight: 20,
            availableGestures: AvailableGestures.none,
            calendarStyle: CalendarStyle(
              canMarkersOverflow: false,
              isTodayHighlighted: true,
              cellAlignment: Alignment.center,
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                shape: BoxShape.circle
                // borderRadius: BorderRadius.circular(20),
                // shape: BoxShape.rectangle
              ),
              todayDecoration: BoxDecoration(
                  color: const Color(0xFFf3ae85),
                shape: BoxShape.circle
                // borderRadius: BorderRadius.circular(20)
              ),
              // cellPadding: EdgeInsets.all(10),
            ),
            onCalendarCreated: (controller){
              print("Calendar created");
              print(controller);
              // setPageController(controller);
              setPageController(controller);
              pageController = controller;
              print(pageController);
            },
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selectedDayNow, focusedDayNow) {
              if (!isSameDay(selectedDayNow, selectedDay)) {
                //TODO: call setState func
                setSelectedDay(selectedDayNow);
                setFocusedDay(focusedDayNow);
                setMantraCounter(0);
                // selectedDay = selectedDayNow;
                // focusedDay = focusedDayNow;
                mantraCounter = 0;

                // var res = getTithiDate(selectedDay,tithiData);
                // // print("ResDateChange: $res");
                // if(res !=30){
                //   setAudioPlayer(res-1);
                // } else {
                //   setAudioPlayer(15);
                // }
              }
            },
            // onFormatChanged: (format) {
            //   if (_calendarFormat != format) {
            //     //TODO: call setState
            //     _calendarFormat = format;
            //   }
            // },
            onPageChanged: (focusedDayNow) {
              focusedDay = focusedDayNow;
            }
        ),
      ],
    );
  }
}
