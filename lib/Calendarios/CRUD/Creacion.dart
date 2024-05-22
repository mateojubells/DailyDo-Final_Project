import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Models/Colors.dart';
import '../../Clases/Recurrence_type.dart';
import '../../Clases/group.dart';
import 'package:http/http.dart' as http;

import '../../UserControll/UserProfile.dart';
import '../../Spotify/SpotifyLogin.dart';
import '../../utils/CreationUtils.dart';
import '../../UserControll/UserProfile.dart';
import 'dart:ui' as ui;
import 'package:daily_doii/utils/NotificationsService.dart';

import '../../utils/NotificationProgramer.dart'; // Asegúrate de importar el archivo adecuado


void main() {
  runApp(AddAppointment());
}

class AddAppointment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Appointment Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddAppointmentForm(),
    );
  }
}

class AddAppointmentForm extends StatefulWidget {
  @override
  _AddAppointmentFormState createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends State<AddAppointmentForm> {
  //VARIABLES DE TRADUCCION
  late String _addTaskTitle = "";
  late String _addTask = "";
  late String _enterName = "";
  late String _date = "";
  late String _start = "";
  late String _end = "";
  late String _description = "";
  late String _recurring = "";
  late String _daily = "";
  late String _weekly = "";
  late String _recurrenceEnd = "";
  late String _addToGroup = "";
  late String _selectgroup = "";
  late String _location = "";
  late String _playlist = "";


  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _addTaskTitle = translations['addTaskTitle'] ?? "";
      _addTask = translations['addTask'] ?? "";
      _enterName = translations['enterName'] ?? "";
      _date = translations['date'] ?? "";
      _start = translations['start'] ?? "";
      _end = translations['end'] ?? "";
      _description = translations['description'] ?? "";
      _recurring = translations['recurring'] ?? "";
      _daily = translations['daily'] ?? "";
      _weekly = translations['weekly'] ?? "";
      _recurrenceEnd = translations['recurrenceEnd'] ?? "";
      _addToGroup = translations['addToGroup'] ?? "";
      _selectgroup = translations['selectgroup'] ?? "";
      _location = translations['location'] ?? "";
      _playlist = translations['playlist'] ?? "";
      print(playlists);
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  BasicColor _selectedColor = BasicColor.blue;
  String ColorSelected = "#FF000";
  String selectedGroup = "";
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedStartTime = TimeOfDay.now();
  late TimeOfDay time = TimeOfDay.now();
  late TimeOfDay _selectedEndTime = TimeOfDay(hour: time.hour + 1, minute: time.minute);
  late TextEditingController _directionController;
  String? _selectedPlaylistId; // Nuevo campo para almacenar el ID de la playlist seleccionada
  List<Group> _userGroups = [];
  String _loggedInUserId = "";
  List<Map<String, dynamic>> playlists = []; // Lista de playlists

  bool _isRecurring = false;
  bool _isInGroup = false;
  RecurrenceType _selectedRecurrence = RecurrenceType.None;
  DateTime? _selectedEndDate;
  bool _isEndlessRecurrence = false;
  bool _isButtonEnabled = false;


  @override
  void initState() {
    CheckTokenExpiration();
    loadTranslations();
    _loadSavedLocale();
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();
    _directionController = TextEditingController();
    _selectedPlaylistId = null;
    getUserId().then((userId) {
      setState(() {
        _loggedInUserId = userId!;
      });
      fetchPlaylists();
    });
  }


  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _directionController.dispose();
    super.dispose();
  }

  void ColorSelect() {
    if (_selectedColor == BasicColor.blue) {
      ColorSelected = "#0000FF";
    } else if (_selectedColor == BasicColor.red) {
      ColorSelected = "#FF0000";
    } else if (_selectedColor == BasicColor.green) {
      ColorSelected = "#00FF00";
    } else if (_selectedColor == BasicColor.purple) {
      ColorSelected = "#800080";
    } else if (_selectedColor == BasicColor.pink) {
      ColorSelected = "#FF007F";
    } else if (_selectedColor == BasicColor.brown) {
      ColorSelected = "#A52A2A";
    } else if (_selectedColor == BasicColor.orange) {
      ColorSelected = "#FFA500";
    } else if (_selectedColor == BasicColor.yellow) {
      ColorSelected = "#EBDD22";
    } else {
      ColorSelected = "#FF0000";
    }
  }


  Future<void> fetchPlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? acces_tocken = prefs.getString('access_token');
    final accessToken = acces_tocken;
    final url = Uri.parse('https://api.spotify.com/v1/me/playlists');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'];

      List<Map<String, dynamic>> playlistData = [];

      for (var item in items) {
        final playlistName = item['name'];
        String? imageUrl;
        if (item['images'] != null && item['images'].isNotEmpty) {
          imageUrl = item['images'][0]['url'];
        }
        final playlistId = item['id'];

        playlistData.add({
          'name': playlistName,
          'image': imageUrl,
          'id': playlistId,
        });
      }

      setState(() {
        playlists = playlistData;
        _selectedPlaylistId = null;
      });
    } else {
      print('Error al obtener las playlists: ${response.statusCode}');
    }
  }



  void _onColorChanged(BasicColor value) {
    setState(() {
      _selectedColor = value;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate)
      setState(() => _selectedDate = picked);
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime)
      setState(() => _selectedStartTime = picked);
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime)
      setState(() => _selectedEndTime = picked);
  }

  Future<void> _selectedGroup(String group) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');
    if (loggedInUserId != null) {
      var snapShotsValue = await FirebaseFirestore.instance
          .collection("Group")
          .where("userId", isEqualTo: loggedInUserId)
          .get();

      List<Map<String, dynamic>> list = [];
      snapShotsValue.docs.forEach((doc) {
        if (doc.id == group) {
          list.add({
            'Color': doc.data()['Color'],
            'Direction': doc.data()['Direction'],
            'Playlist': doc.data()['Playlist'],
          });
        }
      });
      if (list.isNotEmpty) {
        Map<String, dynamic> groupData = list[0];
        String colorHex = groupData['Color'];
        BasicColor? color;
        switch (colorHex) {
          case "#0000FF":
            color = BasicColor.blue;
            break;
          case "#FF0000":
            color = BasicColor.red;
            break;
          case "#00FF00":
            color = BasicColor.green;
            break;
          case "#800080":
            color = BasicColor.purple;
            break;
          case "#FF007F":
            color = BasicColor.pink;
            break;
          case "#A52A2A":
            color = BasicColor.brown;
            break;
          case "#FFA500":
            color = BasicColor.orange;
            break;
          case "#EBDD22":
            color = BasicColor.yellow;
            break;
          default:
            color = BasicColor.red;
        }
        String direction = groupData['Direction'];
        String playlist = groupData['Playlist'];
        setState(() {
          _selectedColor = color!;
          _directionController.text = direction;
          _selectedPlaylistId = playlist;
        });
      }
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    ColorSelect(); // Llamar a ColorSelect() antes de la validación del formulario
    print("El color seleccionado $ColorSelected");
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String notes = _notesController.text.trim();
      String direction = _directionController.text.trim();
      String startTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedStartTime.hour,
          _selectedStartTime.minute,
        ),
      );
      String endTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedEndTime.hour,
          _selectedEndTime.minute,
        ),
      );
      String recurrenceRule = _getRecurrenceRule();

      await addAppointment(
        name,
        notes,
        startTime,
        endTime,
        ColorSelected,
        recurrenceRule,
        selectedGroup,
        direction,
        _selectedPlaylistId ?? "",
      );
    }
  }

  String _getRecurrenceRule() {
    if (!_isRecurring) {
      return '';
    }

    switch (_selectedRecurrence) {
      case RecurrenceType.Daily:
        return _buildRecurrenceRule('DAILY');
      case RecurrenceType.Weekly:
        return _buildRecurrenceRule('WEEKLY');
      case RecurrenceType.Monthly:
        return _buildRecurrenceRule('MONTHLY');
      default:
        return '';
    }
  }

  String _buildRecurrenceRule(String frequency) {
    print("La recurrencia final es $_isEndlessRecurrence");
    if (!_isEndlessRecurrence) {
      if(!_isEndlessRecurrence && frequency == 'WEEKLY' ){
        String selectedDay = _getSelectedDayOfWeek(_selectedDate);
        return 'FREQ=$frequency;BYDAY=$selectedDay;';
      }else{
        return 'FREQ=$frequency';

      }
    } else {
      if (frequency == 'WEEKLY' && _selectedEndDate != null) {
        String selectedDay = _getSelectedDayOfWeek(_selectedDate);
        int days = _selectedEndDate!.difference(_selectedDate).inDays + 2;
        print("dias $days");
        int weeks = (days / 7).ceil();
        print("Las semanas que se aplicará esta tarea son $weeks");
        return 'FREQ=$frequency;BYDAY=$selectedDay;COUNT=${weeks}';
      } else {
        int days = _selectedEndDate!.difference(_selectedDate).inDays;
        return 'FREQ=$frequency;COUNT=${days + 2}';
      }
    }
  }

  String _getSelectedDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'MO';
      case DateTime.tuesday:
        return 'TU';
      case DateTime.wednesday:
        return 'WE';
      case DateTime.thursday:
        return 'TH';
      case DateTime.friday:
        return 'FR';
      case DateTime.saturday:
        return 'SA';
      case DateTime.sunday:
        return 'SU';
      default:
        return '';
    }
  }

  Future<void> addAppointment(
      String subject,
      String notes,
      String startTime,
      String endTime,
      String color,
      String recurrenceRule,
      String group,
      String direction,
      String playlist,
      ) async {
    final db = FirebaseFirestore.instance;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');

    if (loggedInUserId != null) {

      Map<String, dynamic> appointData = {
        "userId": loggedInUserId,
        "Subject": subject,
        "Notes": notes,
        "StartTime": startTime,
        "EndTime": endTime,
        "Color": color,
        "RecurrenceRule": recurrenceRule,
        "Direction": direction,
        "Playlist": playlist,
      };
      if (group != "") {
        appointData["Group"] = group;
      } else {
        appointData["Group"] = "";
      }
      if (!_isInGroup){
        appointData["Group"] = "";
      }


      if (_selectedEndDate != null) {
        appointData["EndDate"] =
            DateFormat('dd/MM/yyyy').format(_selectedEndDate!);
      }
      await db.collection('Appoints').add(appointData);
      TestNotiFi.scheduleMethodExecution(startTime, subject, notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.pop(context); // Volver atrás
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () async {
                      await _submitForm(context);
                      Navigator.pop(context, true);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFb8cbe2),
                      textStyle: TextStyle(
                        color: _isButtonEnabled
                            ? const Color(0xFF495057)
                            : Colors.grey,
                      ),
                    ),
                    child:  Text(
                      _addTask,
                      style: TextStyle(
                        color: Color(0xFF495057),
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _nameController,
                decoration:  InputDecoration(
                  hintText: _addTaskTitle,
                  hintStyle: TextStyle(fontSize: 24, color: Colors.grey),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.blue,
                style: const TextStyle(fontSize: 24),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _enterName;
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isButtonEnabled = value.trim().isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Row(
                      children: [
                        Text(
                          '$_date: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white // Color para modo oscuro
                                : Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white // Color para modo oscuro
                                : Colors.black,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _selectStartTime(context),
                    child: Row(
                      children: [
                        Text(
                          '$_start: ',
                          style:TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white // Color para modo oscuro
                                : Colors.black,
                          ),
                        ),
                        Text(
                          _selectedStartTime.format(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white // Color para modo oscuro
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectEndTime(context),
                    child: Row(
                      children: [
                        Text(
                          '$_end: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white // Color para modo oscuro
                                : Colors.black,
                          ),
                        ),
                        Text(
                          _selectedEndTime.format(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white // Color para modo oscuro
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(color: isDarkMode ? Colors.white24 : Colors.black12),

              const SizedBox(height: 5),
              Text(_description,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white24 : Colors.black12,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                cursorColor: Colors.blue,
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 20),
              Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
              const SizedBox(height: 10),
              Text(_recurring
                ,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Switch(
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value!;
                      });
                    },
                    activeColor: const Color(0xFFb8cbe2),
                  ),
                ],
              ),
              if (_isRecurring)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title:  Text(_daily, style: TextStyle(fontWeight: FontWeight.w300),),
                      value: _selectedRecurrence == RecurrenceType.Daily,
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedRecurrence = value!
                              ? RecurrenceType.Daily
                              : RecurrenceType.None;
                        });
                      },
                      activeColor: const Color(0xFFb8cbe2),
                    ),
                    const SizedBox(width: 10),
                    CheckboxListTile(
                      title:  Text(_weekly, style: TextStyle(fontWeight: FontWeight.w300)),
                      value: _selectedRecurrence == RecurrenceType.Weekly,
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedRecurrence = value!
                              ? RecurrenceType.Weekly
                              : RecurrenceType.None;
                        });
                      },
                      activeColor: const Color(0xFFb8cbe2),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Text('$_recurrenceEnd: '),
                        Checkbox(
                          value: _isEndlessRecurrence,
                          onChanged: (value) {
                            setState(() {
                              _isEndlessRecurrence = value!;
                              if (_isEndlessRecurrence) {
                                _selectedEndDate = null;
                              }
                            });
                          },
                        ),
                        if (_isEndlessRecurrence)
                          TextButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: _selectedDate,
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedEndDate = picked;
                                });
                              }
                            },
                            child: Text(
                              'Date: ${_selectedEndDate != null ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!) : 'Select Date'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Divider(color: isDarkMode ? Colors.white24 : Colors.black12),
              const SizedBox(height: 15),
              Text(
                _addToGroup,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Switch(
                    value: _isInGroup,
                    onChanged: (value) {
                      setState(() {
                        _isInGroup = value!;
                      });
                    },
                    activeColor: const Color(0xFFb8cbe2),
                  ),
                ],
              ),
              if (!_isInGroup)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    const Text("Color",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300
                        )
                    ),
                    SizedBox(height: 5),

                    Row(
                      children: [
                        _colorRadioButton(BasicColor.blue),
                        _colorRadioButton(BasicColor.red),
                        _colorRadioButton(BasicColor.yellow),
                        _colorRadioButton(BasicColor.green),
                        _colorRadioButton(BasicColor.orange),
                        _colorRadioButton(BasicColor.purple),
                        _colorRadioButton(BasicColor.brown),
                        _colorRadioButton(BasicColor.pink),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(_location,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300
                        )
                    ),
                    TextFormField(
                      controller: _directionController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                        filled: true,
                        fillColor: isDarkMode ? Colors.white24 : Colors.black12,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8),
                        ),

                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      cursorColor: Colors.blue,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),

                        Text(
                          _playlist,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedPlaylistId,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: isDarkMode ? Colors.white24 : Colors.black12,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              prefixIcon: Icon(Icons.music_note_rounded)
                          ),
                          items: playlists.map((playlist) {
                            return DropdownMenuItem<String>(
                              value: playlist['id'],
                              child: Row(
                                children: [
                                  if (playlist['image'] != null)
                                    Image.network(
                                      playlist['image'],
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  const SizedBox(width: 10),
                                  Text(playlist['name']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlaylistId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              if (_isInGroup)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Group")
                      .where("userId", isEqualTo: _loggedInUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<DropdownMenuItem<String>> groupItems = [];
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else {
                      final groups = snapshot.data?.docs.reversed.toList();
                      groupItems.add( DropdownMenuItem(
                        value: "",
                        child: Text(_selectgroup),
                      ));
                      for (var group in groups!) {
                        groupItems.add(DropdownMenuItem(
                          value: group.id,
                          child: Text(group['Name']),
                        ));
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          items: groupItems,
                          onChanged: (String? groupValue) {
                            setState(() {
                              selectedGroup = groupValue ?? "";
                            });
                            _selectedGroup(selectedGroup);
                            print("Group value: $groupValue");
                          },
                          value: selectedGroup,
                          isExpanded: false,
                          hint:  Text(_selectgroup),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _colorRadioButton(BasicColor color) {
    return GestureDetector(
      onTap: () => _onColorChanged(color as BasicColor),
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color == _selectedColor ? ColorsHelper.getColorFromEnum(color) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: ColorsHelper.getColorFromEnum(color),
            width: 2,
          ),
        ),
      ),
    );
  }
}