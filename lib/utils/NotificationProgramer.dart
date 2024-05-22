import 'dart:async';
import 'NotificationsService.dart';
import 'package:intl/intl.dart';

class TestNotiFi {
  static void scheduleMethodExecution(String desiredTimeString, String name, String description) {
    DateTime desiredTime = DateFormat('dd/MM/yyyy HH:mm:ss').parse(desiredTimeString);
    Future.delayed(desiredTime.difference(DateTime.now()), () {
      LocalNotifications.showSimpleNotification(
          title: name,
          body: description,
          payload: ""
      );
    });
  }
}
