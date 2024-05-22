import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Calendarios/Pagina Principal.dart';
import '../Calendarios/WeeklyCalendar.dart';
import '../Calendarios/weekCalendar.dart';
import '../Group/GroupList.dart';
import '../Spotify/SpotifyLogin.dart';
import '../UserControll/UserProfile.dart';
import '../services/Auth.dart';
import '../Calendarios/MonthCalendar.dart';
import 'Login.dart';

class CustomDrawer extends StatefulWidget {
  bool isTodaySelected;
  bool isWeekSelected;
  bool isMonthSelected;
  bool isWeeklySelected;
  bool isGroupSelected;
  bool isSettingsSelected;

  CustomDrawer({
    required this.isTodaySelected,
    required this.isWeekSelected,
    required this.isMonthSelected,
    required this.isWeeklySelected,
    required this.isGroupSelected,
    required this.isSettingsSelected
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late String _todayMenuItem = "";
  late String _weekMenuItem = "";
  late String _monthMenuItem = "";
  late String _weeklyMenuItem = "";
  late String _GroupsMenuItem = "";
  late String _settingsMenuItem = "";
  late String _logoutDialogTitle = "";
  late String _logoutDialogContent = "";
  late String _cancelButton = "";
  late String _logoutButton = "";

  final AuthService _authService = AuthService();
  bool spotyLoginStatus = false;
  @override
  void initState() {
    super.initState();
    loadTranslations(); // Load translations at the beginning
    _loadSavedLocale();
    isSpotyLoggedIn();
  }

  Future<void> isSpotyLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spotyLogin = prefs.getString('access_token');
    bool isLoggedIn = spotyLogin != null && spotyLogin.isNotEmpty;
    setState(() {
      spotyLoginStatus = isLoggedIn;
    });
    print(spotyLoginStatus);
  }


  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _todayMenuItem = translations['todayMenuItem'] ?? "";
      _weekMenuItem = translations['weekMenuItem'] ?? "";
      _monthMenuItem = translations['monthMenuItem'] ?? "";
      _weeklyMenuItem = translations['weeklyMenuItem'] ?? "";
      _GroupsMenuItem = translations['groupMenuItem'] ?? "";
      _settingsMenuItem = translations['settingMenuItem'] ?? "";
      _logoutDialogTitle = translations['logoutDialogTitle'] ?? "";
      _logoutDialogContent = translations['logoutDialogContent'] ?? "";
      _cancelButton = translations['cancelButton'] ?? "";
      _logoutButton = translations['logoutButton'] ?? "";
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).canvasColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            margin: const EdgeInsets.only(bottom: 2.0),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'DailyDo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_view_day_rounded,
                color: widget.isTodaySelected
                    ? Colors.blue
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black)
            ),
            title: Text(
              _todayMenuItem,
              style: TextStyle(
                color: widget.isTodaySelected
                    ? Colors.blue
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),              ),
            ),
            selected: widget.isTodaySelected,
            selectedTileColor: (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white),
            onTap: () {

              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_view_week_rounded,
              color: widget.isWeekSelected
                  ? Colors.blue
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
            ),
            selected: widget.isWeekSelected,
            selectedTileColor: (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white),
            title: Text(
              _weekMenuItem,
              style: TextStyle(
                color: widget.isWeekSelected
                    ? Colors.blue
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Weekcalendar()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_view_month,
              color: widget.isMonthSelected
                  ? Colors.blue
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
            ),
            selected: widget.isMonthSelected,
            selectedTileColor: (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white),
            title: Text(
              _monthMenuItem,
              style: TextStyle(
                color: widget.isMonthSelected
                    ? Colors.blue
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MonthCalendar()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.date_range_rounded,
              color: widget.isWeeklySelected
                  ? Colors.blue
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),            ),
            title: Text(
              _weeklyMenuItem,
              style: TextStyle(
                color: widget.isWeeklySelected
                    ? Colors.blue
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),              ),
            ),
            selected: widget.isWeeklySelected,
            selectedTileColor: (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeeklyCalendar()),
              );
            },
          ),
          ListTile(
            title: Text(_GroupsMenuItem,
              style: TextStyle(
                color: widget.isGroupSelected
                    ? Colors.blue
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
              ),
            ),
            selected: widget.isGroupSelected,

            selectedTileColor: (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white),
            leading: Icon(Icons.workspaces, color: widget.isGroupSelected
                ? Colors.blue
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupListScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_rounded,color: widget.isSettingsSelected
                ? Colors.blue
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black) ),
            title: Text(_settingsMenuItem, style: TextStyle(
              color: widget.isSettingsSelected
                  ? Colors.blue
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black),
            ),),
            selected: widget.isSettingsSelected,

            selectedTileColor: (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserView()),
              );
            },
          ),
          if (!spotyLoginStatus)
            ListTile(
              leading: Image.asset(
                'assets/images/spotify.png',
                width: 24, // Tamaño deseado del logo
                height: 24,
              ),
              title: Text(
                "Login Spotify",
              ),
              onTap: () async {
                await RemoteService();
                Navigator.pop(context);
              },
            ),

          Divider(),

          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(_logoutButton,
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
            onTap: () async {
              // Mostrar alerta de confirmación antes de cerrar sesión
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(_logoutDialogTitle),
                    content: Text(_logoutDialogContent),
                    actions: <Widget>[
                      TextButton(
                        child: Text(_cancelButton),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(_logoutButton),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          Navigator.pop(context);
                          await _authService.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                                (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
