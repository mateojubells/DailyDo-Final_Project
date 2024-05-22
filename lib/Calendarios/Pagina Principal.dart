import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'Rehuse/Calendar_page.dart';
import 'dart:ui' as ui;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {

  //VARIABLES DE TRADUCCION
  late String _morinig = "";
  late String _noon = "";
  late String _afternoon = "";
  late String _night = "";
  late String _hola = "";



  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  @override
  void initState() {
    super.initState();
     loadTranslations();
     _loadSavedLocale();
  }


  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _morinig = translations['morning'] ?? "";
      _noon = translations['noon'] ?? "";
      _afternoon = translations['afternoon'] ?? "";
      _night = translations['night'] ?? "";
      _hola = translations['hola'] ?? "";
    });
  }

  Future<void> _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      await loadTranslationsForLocale(savedLocale);
    }
  }

  Future<void> loadTranslationsForLocale(String locale) async {
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);

    _updateTranslations(translations);
  }
  /////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return CalendarPage(
      calendarView: CalendarView.day,
      title: mensaje(),
      isMonthSelected: false,
      isWeekSelected: false,
      daySelected: true,
      isWeeklySelected: false,
      isGroupSelected: false,
      isSettingsSelected: false,
    );
  }

  String mensaje() {
    try {
      int hora = DateTime
          .now()
          .hour;
      if (hora < 11) {
        return _morinig;
      } else if (hora < 16) {
        return _noon;
      } else if (hora < 21) {
        return _afternoon;
      } else {
        return _night;
      }
    } catch (e) {
      return _hola;
    }
  }
}



