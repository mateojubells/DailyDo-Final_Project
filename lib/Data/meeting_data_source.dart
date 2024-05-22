import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../Clases/Meeting.dart';

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime!;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime!;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay!;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject!;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color!;
  }

  @override
  String getRecurrenceRule(int index) {
    String recurrenceRule = appointments![index].recurrenceRule ?? '';
    return recurrenceRule.isNotEmpty ? recurrenceRule : '';
  }

  @override
  String getNotes(int index) {
    return appointments![index].notes!;
  }
}
