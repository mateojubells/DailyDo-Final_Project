import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:daily_doii/Data/meeting_data_source.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import '../../Clases/Meeting.dart';
import '../CRUD/Creacion.dart';
import '../../Data/meeting_data_source.dart';
import '../../Models/Colors.dart';
import '../../Init/menuDesplegable.dart';
import '../CRUD/DetailView.dart';

class WeeklyCalendarPage extends StatelessWidget {
  final CalendarView calendarView;
  final String title;
  final bool daySelected;
  final bool isWeekSelected;
  final bool isMonthSelected;
  final bool isWeeklySelected;

  const WeeklyCalendarPage({
    Key? key,
    required this.calendarView,
    required this.title,
    required this.daySelected,
    required this.isWeekSelected,
    required this.isMonthSelected,
    required this.isWeeklySelected
  }) : super(key: key);

  Future<String?> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('locale');
    return savedLocale;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadLocale(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String? locale = snapshot.data ?? "en"; // Establecer un valor predeterminado si no se encuentra ninguno en las preferencias compartidas
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              SfGlobalLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate, // Agrega este delegado
            ],
            supportedLocales: [
              const Locale('es'),
              const Locale('en'),
              const Locale('ca'),
            ],
            locale: Locale(locale),
            theme: ThemeData(
              brightness: Brightness.light, // Modo claro por defecto
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark, // Modo oscuro
            ),
            title: 'DailyDo',
            home: _CalendarView(
              calendarView: calendarView,
              title: title,
              daySelected: daySelected,
              isMonthSelected: isMonthSelected,
              isWeeklySelected: isWeeklySelected,
              isWeekSelected: isWeekSelected,
            ),
          );
        } else {
          // Muestra un indicador de carga o algún otro widget mientras se carga el idioma
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class _CalendarView extends StatefulWidget {
  final CalendarView calendarView;
  final String title;
  final bool daySelected;
  final bool isWeekSelected;
  final bool isMonthSelected;
  final bool isWeeklySelected;

  const _CalendarView({
    Key? key,
    required this.calendarView,
    required this.title,
    required this.daySelected,
    required this.isWeekSelected,
    required this.isMonthSelected,
    required this.isWeeklySelected

  }) : super(key: key);

  @override
  __CalendarViewState createState() => __CalendarViewState();
}

class __CalendarViewState extends State<_CalendarView> {
  List<Color> _colorCollection = <Color>[];
  List<Meeting> _appointments = [];
  final databaseReference = FirebaseFirestore.instance;

  @override
  void initState() {
    _initializeEventColor();
    _getDataFromFirestore().then((_) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
    super.initState();
  }




  Meeting convertToMeeting(Appointment appointment) {
    if (appointment is Meeting) {
      return appointment;
    } else {
      return Meeting(
        id: appointment.id.toString(),
        subject: appointment.subject,
        notes: appointment.notes.toString(),
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        color: appointment.color,
        isAllDay: appointment.isAllDay,
        recurrenceRule: appointment.recurrenceRule ?? '',
        group: '', // Puedes establecer un valor por defecto para group, direction, playlist, etc.
        direction: '',
        playlist: '',
      );
    }
  }

  Future<Meeting> getRecurrenceData(Appointment appointment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');

    var snapshot = await databaseReference
        .collection("Appoints")
        .where("UserId", isEqualTo: loggedInUserId)
        .where("RecurrenceRule", isNotEqualTo: "")
        .get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      String group = doc['Group'];
      String direction = doc['Direction'];
      String playlist = doc['Playlist'];

      return Meeting(
        id: appointment.id.toString(),
        subject: appointment.subject,
        notes: appointment.notes.toString(),
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        color: ColorsHelper.getColorFromName(doc['Color']),
        isAllDay: appointment.isAllDay,
        recurrenceRule: appointment.recurrenceRule ?? '',
        group: group ?? '',
        direction: direction ?? '',
        playlist: playlist ?? '',
      );
    }

    return Meeting(
      id: appointment.id.toString(),
      subject: appointment.subject,
      notes: appointment.notes.toString(),
      startTime: appointment.startTime,
      endTime: appointment.endTime,
      color: appointment.color,
      isAllDay: appointment.isAllDay,
      recurrenceRule: appointment.recurrenceRule ?? '',
      group: '', // Puedes establecer un valor por defecto para group, direction, playlist, etc.
      direction: '',
      playlist: '',
    );
  }

  Future<void> _getDataFromFirestore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');

    var snapshot = await databaseReference
        .collection("Appoints")
        .where("userId", isEqualTo: loggedInUserId)
        .where("RecurrenceRule", isNotEqualTo: "")
        .get();

    List<Meeting> list = snapshot.docs.map((doc) {

      return Meeting(
        id: doc.id,
        subject: doc['Subject'],
        startTime: DateFormat('dd/MM/yyyy HH:mm:ss').parse(doc['StartTime']),
        endTime: DateFormat('dd/MM/yyyy HH:mm:ss').parse(doc['EndTime']),
        color: _getColorFromRGBString(doc['Color']),
        isAllDay: false,
        recurrenceRule: doc['RecurrenceRule'],
        notes: doc['Notes'],
        group: doc['Group'],
        direction: doc['Direction'],
        playlist: doc['Playlist'],
      );
    }).toList();
    setState(() {
      _appointments = list;
    });
  }


  Future<void> _refreshCalendar(bool addedAppointment) async {
    if (addedAppointment) {
      await _getDataFromFirestore();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: CustomDrawer(isTodaySelected: false, isMonthSelected: false, isWeekSelected: false, isWeeklySelected: true, isGroupSelected: false, isSettingsSelected: false),
      body: SfCalendar(
        view: widget.calendarView,
        initialDisplayDate: DateTime.now(),
        dataSource: MeetingDataSource(_appointments),
        monthViewSettings: MonthViewSettings(
          showAgenda: true,
        ),
        onTap: (calendarTapDetails) {
          if (calendarTapDetails.targetElement == CalendarElement.appointment) {
            _handleAppointmentTap(calendarTapDetails.appointments![0]);
          }
        },
        onLongPress: (calendarLongPressDetails) {
          if (calendarLongPressDetails.targetElement == CalendarElement.appointment) {
            _showLongPressDialog(calendarLongPressDetails.appointments![0]);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAppointmentForm(),
            ),
          );
          _refreshCalendar(result == true);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _initializeEventColor() {
    for (var color in BasicColor.values) {
      _colorCollection.add(ColorsHelper.getColorFromEnum(color));
    }
  }

  void _handleAppointmentTap(Appointment appointment) {
    getRecurrenceData(appointment).then((meeting) {
      _openDetailView(meeting);
    });
  }

  void _openDetailView(Meeting meeting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailView(appointment: meeting),
      ),
    ).then((result) {
      // Verifica el resultado y actualiza el calendario si es necesario
      if (result != null && result) {
        _refreshCalendar(true);
      }
    });
  }

  void _showLongPressDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Appointment"),
          content: Text("Are you sure you want to delete this appointment?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAppointment(appointment.id.toString());
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Appoints")
          .doc(appointmentId)
          .delete();

      _refreshCalendar(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Appointment deleted successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete appointment'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Color _getColorFromRGBString(String rgbString) {
    // Elimina el # inicial si está presente
    if (rgbString.startsWith('#')) {
      rgbString = rgbString.substring(1);
    }

    try {
      // Dividir el RGB en sus componentes R, G y B
      int r = int.parse(rgbString.substring(0, 2), radix: 16);
      int g = int.parse(rgbString.substring(2, 4), radix: 16);
      int b = int.parse(rgbString.substring(4, 6), radix: 16);

      // Devuelve un objeto Color con los componentes RGB
      return Color.fromRGBO(r, g, b, 1.0);
    } catch (e) {
      // Manejo de errores en caso de que la conversión falle
      print("Error al convertir el color: $rgbString");
      return Colors.grey; // Puedes usar otro color por defecto
    }
  }

}
