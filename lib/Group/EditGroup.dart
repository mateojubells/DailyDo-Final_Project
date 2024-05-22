import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Clases/group.dart';
import '../Models/Colors.dart';
import 'dart:ui' as ui;

class GroupEdit extends StatefulWidget {

  final Group group;

  GroupEdit({required this.group});

  @override
  _GroupEditState createState() => _GroupEditState();
}

class _GroupEditState extends State<GroupEdit> {
  //VARIABLES DE TRADUCCION
  late String _name = "";
  late String _direction = "";
  late String _playlist = "";
  late String _update = "";
  late String _groupCreated = "";
  late String _groupExistsAlready = "";
  late String _enterName = "";
  late String _editGroup = "";


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
      _update = translations['update'] ?? "";
      _groupCreated = translations['groupCreated'] ?? "";
      _groupExistsAlready = translations['groupExists'] ?? "";
      _enterName = translations['enterName'] ?? "";
      _editGroup = translations['editGroup'] ?? "";
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
  BasicColor _selectedColor = BasicColor.red; // O cualqu
  String ColorSelected = "";

  List<Map<String, dynamic>> playlists = [];

  @override
  void initState() {
    super.initState();
    _selectedPlaylistId = widget.group.Playlist;
    _nameController.text = widget.group.Name!;
    _directionController.text = widget.group.Direction!;
    ColorValue().then((color) {
      setState(() {
        _selectedColor = color;
      });
    });
    fetchPlaylists();
    loadTranslations();
    _loadSavedLocale();

    if (_selectedPlaylistId == null || _selectedPlaylistId!.isEmpty) {
      _selectedPlaylistId = null;
    }
  }


  Future<BasicColor> ColorValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');

    var snapShotsValue = await FirebaseFirestore.instance
        .collection("Group")
        .where("Name", isEqualTo: widget.group.Name)
        .where("userId", isEqualTo: loggedInUserId)
        .get();
    print(widget.group.Name);
    print(loggedInUserId);

    if (snapShotsValue.docs.isNotEmpty) {
      String colorHex = snapShotsValue.docs.first.data()['Color'];
      print("El color de inicio es $colorHex");
      switch (colorHex) {
        case "#0000FF":
          return BasicColor.blue;
        case "#FF0000":
          return BasicColor.red;
        case "#00FF00":
          return BasicColor.green;
        case "#800080":
          return BasicColor.purple;
        case "#FF007F":
          return BasicColor.pink;
        case "#A52A2A":
          return BasicColor.brown;
        case "#FFA500":
          return BasicColor.orange;
        case "#EBDD22":
          return BasicColor.yellow;
        default:
          return BasicColor.red;
      }
    } else {
      // Si no se encuentra ningún color, puedes devolver un valor predeterminado
      return BasicColor.red;
    }
  }


  Color getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor.replaceAll("#", ""), radix: 16) + 0xFF000000);
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
      });
    } else {
      print('Error al obtener las playlists: ${response.statusCode}');
    }
  }

  void _onColorChanged(BasicColor newColor) {
    setState(() {
      _selectedColor = newColor;
      ColorSelect();
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

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic>? groupData = querySnapshot.docs.first.data() as Map<String, dynamic>?;

      if (groupData != null && groupData['Name'] == groupName) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  Future<void> _submitForm() async {
    ColorSelect();
    if (_selectedPlaylistId == null) {
      _selectedPlaylistId = "";
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');

    print("Group Name to Update: ${widget.group.Name}");
    print("Logged In User ID: $loggedInUserId");

    if (_formKey.currentState!.validate()) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Group")
          .where("Name", isEqualTo: widget.group.Name)
          .where("userId", isEqualTo: loggedInUserId)
          .get();


      if (querySnapshot.docs.isNotEmpty) {
        updateAppointsAfterGroupUpdate(_nameController.text,_directionController.text,_selectedPlaylistId!,ColorSelected);
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({
            "Name": _nameController.text,
            "Direction": _directionController.text,
            "Playlist": _selectedPlaylistId,
            "Color": ColorSelected,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_groupCreated),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print("No se encontraron documentos para actualizar.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editGroup),
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
                ),
                ),

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
                    fontSize: 16,
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
                          Navigator.of(context).pop();
                        },
                        child: Text(_update, style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 120.0),
                          elevation: 0,
                          backgroundColor: const Color(0xFFB8CBE2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                        ),
                      ),
                    ]
                )
              ],
            ),
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
  Future<void> updateAppointsAfterGroupUpdate(String groupName, String newGroupDirection, String newGroupPlaylist, String newGroupColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');

    QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
        .collection("Group")
        .where("Name", isEqualTo: groupName)
        .where("userId", isEqualTo: loggedInUserId)
        .get();

    if (groupSnapshot.docs.isNotEmpty) {
      String groupId = groupSnapshot.docs.first.id;
      print(groupId);
      // Actualizar los Appoints con el nuevo direction, playlist y color
      FirebaseFirestore.instance
          .collection("Appoints")
          .where("Group", isEqualTo: groupId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({
            "Direction": newGroupDirection,
            "Playlist": newGroupPlaylist,
            "Color": newGroupColor,
          }).then((value) {
            print("Campos del Appoint actualizados para el Appoint con ID: ${doc.id}");
          }).catchError((error) => print("Error al actualizar Appoint: $error"));
        });
      }).catchError((error) => print("Error al buscar Appoints: $error"));
    } else {
      print("No se encontró ningún grupo con el nombre proporcionado y el ID de usuario.");
    }
  }

}
