import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Meeting extends Appointment {
  String? group;
  String? direction;
  String? playlist;

  Meeting({
    this.group,
    this.direction,
    this.playlist,
    required DateTime startTime,
    required DateTime endTime,
    required String subject,
    required String notes,
    required Object id,
    required Color color,
    required bool isAllDay,
    required String recurrenceRule,
  }) : super(
    startTime: startTime,
    endTime: endTime,
    subject: subject,
    notes: notes,
    id: id,
    color: color,
    isAllDay: isAllDay,
    recurrenceRule: recurrenceRule,
  );
}
