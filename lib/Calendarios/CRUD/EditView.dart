import 'dart:convert';

import 'package:daily_doii/Clases/Meeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../Models/Colors.dart';
import '../../Clases/group.dart';
import '../../Spotify/SpotifyLogin.dart';
import '../../utils/CreationUtils.dart';
import 'dart:ui' as ui;

import '../Pagina Principal.dart';

void main() {
  runApp(EditAppointment());
}

class EditAppointment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Appointment Form',
    );
  }
}

class EditAppointmentForm extends StatefulWidget {
  final Meeting appointment;

  EditAppointmentForm({required this.appointment});

  @override
  _EditAppointmentFormState createState() => _EditAppointmentFormState();
}

class _EditAppointmentFormState extends State<EditAppointmentForm> {

  //VARIABLES DE TRADUCCION
  late String _titleEdit = "";
  late String _addTaskTitle = "";
  late String _editTask = "";
  late String _enterName = "";
  late String _date = "";
  late String _start = "";
  late String _end = "";
  late String _description = "";
  late String _addToGroup = "";
  late String _selectgroup = "";
  late String _location = "";
  late String _changePlaylist = "";
  late String _playlist = "";


  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _titleEdit = translations['titleEdit'] ?? "";
      _addTaskTitle = translations['addTaskTitle'] ?? "";
      _editTask = translations['editTask'] ?? "";
      _enterName = translations['enterName'] ?? "";
      _date = translations['date'] ?? "";
      _start = translations['start'] ?? "";
      _end = translations['end'] ?? "";
      _description = translations['description'] ?? "";
      _addToGroup = translations['addToGroup'] ?? "";
      _selectgroup = translations['selectgroup'] ?? "";
      _location = translations['location'] ?? "";
      _playlist = translations['playlist'] ?? "";
      _changePlaylist = translations['changePlaylist'] ?? "";
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  BasicColor _selectedColor = BasicColor.blue;
  String ColorSelected = "#FF000";
  String selectedGroup = "";
  String? selectedGroupInicial;
  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late TextEditingController _directionController;
  String? _selectedPlaylistId;
  String? selectedPlaylistId;
  List<Group> _userGroups = [];
  String _loggedInUserId = "";
  List<Map<String, dynamic>> playlists = [];
  bool isInGroup = false;
  bool editPlaylist = false;
  bool _isButtonEnabled = true;


  @override
  void initState() {
    super.initState();
    CheckTokenExpiration();
    loadTranslations();
    _loadSavedLocale();
    _nameController = TextEditingController(text: widget.appointment.subject);
    _notesController = TextEditingController(text: widget.appointment.notes);
    _selectedColor = ColorsHelper.getColorBasic(widget.appointment.color);
    print("El color es $_selectedColor");
    selectedGroup = widget.appointment.group!;
    selectedGroupInicial = widget.appointment.group;
    _selectedDate = widget.appointment.startTime ?? DateTime.now();
    _selectedStartTime =
        TimeOfDay.fromDateTime(widget.appointment.startTime ?? DateTime.now());
    _selectedEndTime =
        TimeOfDay.fromDateTime(widget.appointment.endTime ?? DateTime.now());
    _directionController =
        TextEditingController(text: widget.appointment.direction ?? "");
    _selectedPlaylistId = widget.appointment.playlist ?? "";
    selectedPlaylistId = widget.appointment.playlist ?? "";
    isInGroups();
    _selectedGroup(widget.appointment.group.toString());
    ColorValue();
    getUserId().then((userId) {
      setState(() {
        _loggedInUserId = userId!;
      });
      _fetchUserGroups();
      fetchPlaylists();
    });
  }

  Future<void> ColorValue() async {
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("Appoints")
        .where(FieldPath.documentId,
            isEqualTo: widget.appointment.id.toString())
        .get();

    if (snapShotsValue.docs.isNotEmpty) {
      String colorHex = snapShotsValue.docs.first.data()[
          'Color']; // Aquí asumo que el campo en la base de datos se llama 'color'

      switch (colorHex) {
        case "#0000FF":
          _selectedColor = BasicColor.blue;
          break;
        case "#FF0000":
          _selectedColor = BasicColor.red;
          break;
        case "#00FF00":
          _selectedColor = BasicColor.green;
          break;
        case "#800080":
          _selectedColor = BasicColor.purple;
          break;
        case "#FF007F":
          _selectedColor = BasicColor.pink;
          break;
        case "#A52A2A":
          _selectedColor = BasicColor.brown;
          break;
        case "#FFA500":
          _selectedColor = BasicColor.orange;
          break;
        case "#EBDD22":
          _selectedColor = BasicColor.yellow;
          break;
        default:
          _selectedColor = BasicColor.red;
      }
    }
  }

  String getColorNameFromHex(String hexColor) {
    switch (hexColor.toUpperCase()) {
      case "#0000FF":
        return "blue";
      case "#FF0000":
        return "red";
      case "#00FF00":
        return "green";
      case "#800080":
        return "purple";
      case "#FF007F":
        return "pink";
      case "#A52A2A":
        return "brown";
      case "#FFA500":
        return "orange";
      case "#EBDD22":
        return "yellow";
      default:
        return "red"; // Color por defecto en caso de no coincidir
    }
  }

  void ColorSelect() {
    if (_selectedColor == BasicColor.blue) {
      ColorSelected = "#0000FF"; // Cambiado el color azul a #0000FF
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

  void isInGroups() {
    if (selectedGroup == "" || selectedGroup == null) {
      isInGroup = false;
    } else {
      isInGroup = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _directionController.dispose();
    super.dispose();
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

  Future<void> _fetchUserGroups() async {
    if (_loggedInUserId.isNotEmpty) {
      var snapShotsValue = await FirebaseFirestore.instance
          .collection("Group")
          .where("userId", isEqualTo: _loggedInUserId)
          .get();

      List<Group> list = snapShotsValue.docs.map((e) {
        return Group(
          Name: e.data()['Name'],
          Color: e.data()['Color'],
          Direction: e.data()['Direction'],
          Playlist: e.data()['Playlist'],
        );
      }).toList();

      setState(() {
        _userGroups = list;
      });
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
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() => _selectedStartTime = picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() => _selectedEndTime = picked);
    }
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

  void switchOptions() {
    print(isInGroup);
    if (!isInGroup) {
      selectedGroup = "";
    }
    if (selectedGroup == selectedGroupInicial && selectedGroup != "") {
      _selectedPlaylistId = selectedPlaylistId;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    ColorSelect();
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
      String? recurrenceRule = widget.appointment.recurrenceRule;
      switchOptions(); // Actualizar los valores según el estado actual
      await editAppointment(
        widget.appointment.id.toString(),
        name,
        notes,
        startTime,
        endTime,
        ColorSelected,
        recurrenceRule!,
        selectedGroup!,
        direction,
        _selectedPlaylistId ?? "",
      );
    }
  }

  Future<void> editAppointment(
    String id,
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
      print("El id de la tarea es $id");
      await db.collection('Appoints').doc(id).update(appointData);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleEdit),
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
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    }
                        : null,
                    child: Text(_editTask, style: TextStyle(color: Colors.black),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFb8cbe2),
                      textStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
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
                style: const TextStyle(
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
                    value: isInGroup,
                    onChanged: (value) {
                      setState(() {
                        isInGroup = value;
                      });
                    },
                    activeColor: const Color(0xFFb8cbe2),
                  ),
                ],
              ),
              if (isInGroup)
                Visibility(
                  visible: isInGroup == true,
                  child: StreamBuilder<QuerySnapshot>(
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            DropdownButton<String>(
                              items: groupItems,
                              onChanged: (String? groupValue) {
                                setState(() {
                                  selectedGroup = groupValue ?? "";
                                });
                                _selectedGroup(selectedGroup!);
                                print("Group value: $groupValue");
                              },
                              value: selectedGroup,
                              isExpanded: false,
                              hint: Text(_selectgroup),
                            ),
                            const SizedBox(height: 30),
                          ],
                        );
                      }
                    },
                  ),
                ),
              if (!isInGroup)
                Visibility(
                  visible: isInGroup == false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(_location,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300
                          )
                      ),
                      TextFormField(
                        controller: _directionController,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 16, 12, 16),
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text("$_changePlaylist    "),
                          Switch(
                            value: editPlaylist,
                            onChanged: (value) {
                              setState(() {
                                editPlaylist = value;
                              });
                            },
                            activeColor: const Color(0xFFb8cbe2),
                          ),
                        ],
                      ),
                      if (editPlaylist)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              _playlist,
                              style: TextStyle(
                                fontSize: 16,
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                contentPadding:  const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              items: playlists.map((playlist) {
                                print(_selectedPlaylistId);
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
                                  print("2 $_selectedPlaylistId");
                                });
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
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
          color: color == _selectedColor
              ? ColorsHelper.getColorFromEnum(color)
              : Colors.transparent,
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
