import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Widgets/calendarHeader.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({Key? key}) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final kToday = DateTime.now();
  DateTime? kFirstDay;
  DateTime? kLastDay;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("CalendarApp"),),
        body: Column(
          children: [
            // ValueListenableBuilder<DateTime>(
            //   valueListenable: _focusedDay,
            //   builder: (context, value, _) {
            //     return CalendarHeader(
            //       focusedDay: value,
            //       // clearButtonVisible: canClearSelection,
            //       onTodayButtonTap: () {
            //         setState(() => _focusedDay.value = DateTime.now());
            //       },
            //       onLeftArrowTap: () {
            //         _pageController.previousPage(
            //           duration: const Duration(milliseconds: 300),
            //           curve: Curves.easeOut,
            //         );
            //       },
            //       onRightArrowTap: () {
            //         _pageController.nextPage(
            //           duration: const Duration(milliseconds: 300),
            //           curve: Curves.easeOut,
            //         );
            //       },
            //       onClearButtonTap: () {},
            //       clearButtonVisible: false,
            //     );
            //   },
            // ),
            TableCalendar(
                focusedDay: _focusedDay,
                firstDay: kFirstDay!,
                lastDay: kLastDay!,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
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
            const Spacer(flex: 1),
            Text("Selected Date: ${_selectedDay!.day}:${_selectedDay!.month}:${_selectedDay!.year}"),
            const Spacer(flex:1),

          ],
        ),
      ),
    );
  }
}
