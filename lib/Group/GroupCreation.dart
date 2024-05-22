import 'dart:convert';

import 'package:daily_doii/Group/GroupList.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/Colors.dart';
import '../Spotify/SpotifyLogin.dart';
import '../utils/CreationUtils.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class GroupCreation extends StatefulWidget {
  @override
  _GroupCreationState createState() => _GroupCreationState();
}

class _GroupCreationState extends State<GroupCreation> {
  //VARIABLES DE TRADUCCION
  late String _name = "";
  late String _direction = "";
  late String _playlist = "";
  late String _submit = "";
  late String _groupCreated = "";
  late String _groupExistsAlready = "";
  late String _enterName = "";
  late String _addgroup = "";


  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _name = translations['nameLabel'] ?? "";
      _direction = translations['direction'] ?? "";
      _playlist = translations['playlist'] ?? "";
      _submit = translations['submit'] ?? "";
      _groupCreated = translations['groupCreated'] ?? "";
      _groupExistsAlready = translations['groupExists'] ?? "";
      _enterName = translations['enterName'] ?? "";
      _addgroup = translations['addgroup'] ?? "";
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _directionController = TextEditingController();
  String? _selectedPlaylistId;
  BasicColor _selectedColor = BasicColor.blue;
  String _userId = "";
  String ColorSelected = "#FF000";

  List<Map<String, dynamic>> playlists = [];

  @override
  void initState() {
    super.initState();
    _selectedPlaylistId = null;
    CheckTokenExpiration();
    getUserId().then((userId) {
      setState(() {
        _userId = userId!;
      });
      fetchPlaylists();
    });
    loadTranslations();
    _loadSavedLocale();
  }

  Future<void> fetchPlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
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

  void _onColorChanged(BasicColor newColor) {
    setState(() {
      _selectedColor = newColor;
    });
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

  Future<void> _checkGroupNameAndSubmit() async {
    String groupName = _nameController.text.trim();

    bool groupExists = await _groupExists(groupName);

    if (groupExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_groupExistsAlready),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await _submitForm();
    }
  }

  Future<bool> _groupExists(String groupName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Group")
        .where("Name", isEqualTo: groupName)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _submitForm() async {
    ColorSelect();
    if (_selectedPlaylistId == null) {
      _selectedPlaylistId = "";
    }

    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection("Group").add({
        "Name": _nameController.text,
        "Direction": _directionController.text,
        "Playlist": _selectedPlaylistId,
        "Color": ColorSelected,
        "userId": _userId,
      });

      _nameController.clear();
      _directionController.clear();
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_groupCreated),
          duration: Duration(seconds: 2),
        ),

      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          title: Text(_addgroup),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_name, style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black // Color para modo oscuro
                            : Colors.grey,),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: isDarkMode ? Colors.white24 : Colors.white,
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    cursorColor: Colors.blue,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _enterName;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  Text(_direction, style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                  TextFormField(
                    controller: _directionController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black // Color para modo oscuro
                            : Colors.grey,),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: isDarkMode ? Colors.white24 : Colors.white,
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    cursorColor: Colors.blue,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _playlist,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        _selectedPlaylistId = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  const Text("Color",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _checkGroupNameAndSubmit();
                        },
                        child: Text(_submit, style: TextStyle(color: Colors.black),),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 120.0),
                          elevation: 0,
                          backgroundColor: const Color(0xFFB8CBE2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                        ),
                      ),

                    ],
                  )

                ],
              ),
            ),
          ),)
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