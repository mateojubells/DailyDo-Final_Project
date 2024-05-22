import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'Rehuse/Calendar_page.dart';
import 'dart:ui' as ui;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MonthCalendar());
}

class MonthCalendar extends StatefulWidget {
  @override
  _MonthCalendarState createState() => _MonthCalendarState();
}
class _MonthCalendarState extends State<MonthCalendar> {  //VARIABLES DE TRADUCCION
  late String _month = "";

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
      _month = translations['month'] ?? "";
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
    return  CalendarPage(
      calendarView: CalendarView.month,
      title: _month,
      daySelected: false,
      isWeekSelected: false,
      isWeeklySelected: false,
      isMonthSelected: true,
      isGroupSelected: false,
      isSettingsSelected: false,
    );
  }
}