import 'package:daily_doii/Calendarios/Rehuse/WeeklyCalendarPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(WeeklyCalendar());
}

class WeeklyCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const WeeklyCalendarPage(
      calendarView: CalendarView.week,
      title: 'WeeklyCalendar™',
      isMonthSelected: false,
      isWeekSelected: false,
      daySelected: true,
      isWeeklySelected: false,
    );
  }
}
