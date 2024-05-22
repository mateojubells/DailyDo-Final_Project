
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Clases/Meeting.dart';
import '../Pagina Principal.dart';
import '../Rehuse/Calendar_page.dart';
import 'Month.dart';
import 'EditView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Spotify/SpotifyLogin.dart';
import 'dart:ui' as ui;
import '../../Models/Colors.dart';


class DetailView extends StatefulWidget {
  final Meeting appointment;

  DetailView({required this.appointment});

  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {

  //Translations

  late String _description = "";
  late String _group = "";
  late String _direction = "";
  late String _openSpotify = "";
  late String _playlist = "";
  late String _delete = "";
  late String _notAssigned = "";
  late String _deleteAppointment = "";
  late String _sureDeteleAppointment = "";
  late String _cancelButton = "";

  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent =
    await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _description = translations['description'] ?? "";
      _group = translations['group'] ?? "";
      _direction = translations['direction'] ?? "";
      _openSpotify = translations['openSpotify'] ?? "";
      _delete = translations['delete'] ?? "";
      _notAssigned = translations['notAssigned'] ?? "";
      _playlist = translations['playlist'] ?? "";
      _sureDeteleAppointment = translations['sureDeteleAppointment'] ?? "";
      _deleteAppointment = translations['deleteAppointment'] ?? "";
      _cancelButton = translations['cancelButton'] ?? "";
      playlistName = _openSpotify;
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
    String jsonContent =
    await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);

    _updateTranslations(translations);
  }

  Color appointmentColor = Colors.black;

  Future<void> getAppointmentColor() async {
    try {
      DocumentSnapshot appointmentSnapshot = await FirebaseFirestore.instance
          .collection("Appoints")
          .doc(widget.appointment.id.toString())
          .get();
      if (appointmentSnapshot.exists) {
        String? hexColor = appointmentSnapshot.get('Color');

        if (hexColor != null && hexColor.isNotEmpty && hexColor.length == 7 && hexColor[0] == '#') {
          appointmentColor = Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
          setState(() {}); // Forzar un rebuild del widget
        }
      }
    } catch (e) {
      print('Error al obtener el color de la cita: $e');
    }
  }


  late String playlistName = '';
  String playlistImage = '';
  final databaseReference = FirebaseFirestore.instance;
  String groupName = '';
  late String colorName = '';


  late int startDay, startMonth, startYear, startHour, startMinute;
  late int endDay, endMonth, endYear, endHour, endMinute;
  late String StartMonthLetters, completeStartDate, completeEndDate, minutesStartString, minutesEndString, dayOfWeek;

  @override
  void initState() {
    super.initState();
    CheckTokenExpiration();
    getAppointmentColor();
    getGroup();
    getColorName();

    if (widget.appointment.playlist != null) {
      fetchPlaylistDetails(widget.appointment.playlist!);
    }
    loadTranslations();
    _loadSavedLocale();
    print(_openSpotify);
    print(playlistName);

    DateTime? startTime = widget.appointment.startTime;
    DateTime? endTime = widget.appointment.endTime;

    if (startTime != null && endTime != null) {
      startDay = startTime.day;
      startMonth = startTime.month;
      startYear = startTime.year;
      startHour = startTime.hour;
      startMinute = startTime.minute;
      completeStartDate = '$startDay/$startMonth/$startYear';

      endDay = endTime.day;
      endMonth = endTime.month;
      endYear = endTime.year;
      endHour = endTime.hour;
      endMinute = endTime.minute;
      completeStartDate = '$startDay/$startMonth/$startYear';
      StartMonthLetters = getMonthName(startTime.month);


      minutesStartString = startTime.minute.toString();
      minutesEndString = endTime.minute.toString();

      if (startMinute < 9) {
        minutesStartString = '0$startMinute';
      }
      if (endMinute < 9) {
        minutesEndString = '0$endMinute';
      }
    }


  }



  Future<void> getGroup() async {
    var snapshot = await databaseReference
        .collection("Group")
        .where(FieldPath.documentId, isEqualTo: widget.appointment.group)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      groupName = doc['Name'];
      print(groupName);
    }
  }

  Future<void> fetchPlaylistDetails(String playlistId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    final url = Uri.parse('https://api.spotify.com/v1/playlists/$playlistId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      playlistName = data['name'];
      if (data['images'] != null && data['images'].isNotEmpty) {
        playlistImage = data['images'][0]['url'];
      }
      setState(() {});
    } else {
      print('Error al obtener la playlist: ${response.statusCode} ');
    }
  }

  Future<void> getColorName() async {
    switch (widget.appointment.color) {
      case Colors.red:
        colorName = 'Rojo';
        break;
      case Colors.blue:
        colorName = 'Azul';
        break;
      case Colors.green:
        colorName = 'Verde';
        break;
      case Colors.yellow:
        colorName = 'Amarillo';
        break;
      case Colors.orange:
        colorName = 'Naranja';
        break;
      case Colors.purple:
        colorName = 'Morado';
        break;
      case Colors.pink:
        colorName = 'Rosado';
        break;
      case Colors.brown:
        colorName = 'Marron';
        break;
      default:
        colorName = 'Desconocido';
        break;
    }
    setState(() {});
  }

  void openSpotifyPlaylist(String playlistId) async {
    final url = 'https://open.spotify.com/playlist/$playlistId';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir $url';
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAppointmentForm(appointment: widget.appointment),
                  ),
                );
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                deleteAppointment(widget.appointment.id.toString());
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color : appointmentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.appointment.subject,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$StartMonthLetters $startDay, $startYear',style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400
                    ),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.circle_rounded, size: 6, color: Colors.grey),
                    SizedBox(width: 5),

                    Text('$startHour:$minutesStartString-$endHour:$minutesEndString',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300
                        )
                    ),
                  ],
                ),
              ],
            ),
            Divider(thickness: 2, color: isDarkMode ? Colors.white70 : Colors.black12,),
            const SizedBox(height: 10),
            Text(_description, style: TextStyle(
              fontSize: 20,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,),),
            Text(widget.appointment.notes ?? '',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w200
                )
            ),


            const SizedBox(height: 10),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _group,
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,)
                ),
                SizedBox(height: 8),
                if (widget.appointment.group?.isNotEmpty ?? false)
                  Row(
                    children: [
                      Icon(
                        Icons.group_work_outlined,
                        color: Colors.black54,
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                if (widget.appointment.group?.isEmpty ?? true)
                   Text(
                    _notAssigned,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _direction,
                    style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,)
                ),
                const SizedBox(height: 8),
                if (widget.appointment.direction?.isNotEmpty ?? false)
                  Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.appointment.direction!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                if (widget.appointment.direction?.isEmpty ?? true)
                   Text(
                    _notAssigned,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
            const SizedBox(height: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _playlist,
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.appointment.playlist != null)
                  ListTile(
                    leading: playlistImage.isNotEmpty
                        ? Image.network(
                      playlistImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.music_note),
                    ),
                    title: Text(playlistName, style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                    ),
                    onTap: () {
                      openSpotifyPlaylist(widget.appointment.playlist!);
                    },
                  ),
              ],
            ),
            Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  Future<void> deleteAppointment(String appointmentId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_deleteAppointment),
          content: Text(_sureDeteleAppointment),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_cancelButton),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection("Appoints")
                      .doc(appointmentId)
                      .delete();

                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                } catch (e) {
                }
              },
              child: Text(_delete),
            ),
          ],
        );
      },
    );
  }


}
