import 'package:daily_doii/Init/menuDesplegable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Clases/group.dart';
import '../Data/RehuseCommands.dart';
import 'EditGroup.dart';
import 'GroupCreation.dart';
import 'dart:ui' as ui;

void main() {
  runApp(GroupList());
}

class GroupList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GroupListScreen(),

    );
  }
}

class GroupListScreen extends StatefulWidget {
  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  //VARIABLES DE TRADUCCION
  late String _groupList = "";


  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _groupList = translations['groupList'];
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

  bool isTodaySelected = false;
  bool isWeekSelected = false;
  bool isMonthSelected = false;
  bool isWeeklySelected = false;
  bool isGroupSelected = true;
  bool isSettingsSelected = false;

  String? userId;

  @override
  void initState() {
    super.initState();
    logedInUser().then((value) {
      setState(() {
        userId = value;
      });
    });
    loadTranslations();
    _loadSavedLocale();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupList),
      ),
      drawer: CustomDrawer(
        isTodaySelected: isTodaySelected,
        isWeekSelected: isWeekSelected,
        isMonthSelected: isMonthSelected,
        isWeeklySelected: isWeeklySelected,
        isGroupSelected: isGroupSelected,
        isSettingsSelected: isSettingsSelected,
      ),
      body: userId == null ? _buildLoadingIndicator() : _buildGroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupCreation()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildGroupList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Group')
          .where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Group> groups = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Group(
            Name: data['Name'],
            Color: data['Color'],
            Direction: data['Direction'],
            Playlist: data['Playlist'],
          );
        }).toList();

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return GroupListItem(group: groups[index]);
          },
        );
      },
    );
  }

}



class GroupListItem extends StatefulWidget {

  final Group group;

  GroupListItem({required this.group});

  @override
  _GroupListItemState createState() => _GroupListItemState();
}

class _GroupListItemState extends State<GroupListItem> {
  //VARIABLES DE TRADUCCION
  late String _playlist = "";
  late String _direction = "";
  late String _deleteGroup = "";
  late String _sureDeleteGroup = "";
  late String _cancel = "";
  late String _delete = "";

  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _playlist = translations['playlist'] ?? "";
      _direction = translations['direction'] ?? "";
      _deleteGroup = translations['deleteGroup'] ?? "";
      _sureDeleteGroup = translations['sureDeleteGroup'] ?? "";
      _cancel = translations['cancelButton'] ?? "";
      _delete = translations['delete'] ?? "";
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
  String playlistName = '';
  String playlistImage = '';

  @override
  void initState() {
    super.initState();
    if (widget.group.Playlist != "") {
      fetchPlaylistDetails(widget.group.Playlist!);
    }
    loadTranslations();
    _loadSavedLocale();
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
      setState(() {
        playlistName = data['name'];
        if (data['images'] != null && data['images'].isNotEmpty) {
          playlistImage = data['images'][0]['url'];
        }
      });
    } else {
      print('Error al obtener la playlist: ${response.statusCode} ');
    }
  }

  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: getColorFromHex(widget.group.Color!).withOpacity(0.4),
      child: InkWell(
        onTap: () {
          print(playlistName);
        },
        onLongPress: () {
          _showDeleteDialog(context);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                child: playlistImage.isNotEmpty
                    ? Image.network(
                  playlistImage,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.music_note),
              ),
              SizedBox(width: 16),
              Flexible( // O Expanded, dependiendo del comportamiento deseado
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.Name!,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Recorta el texto si es muy largo
                      maxLines: 1, // Limita a una sola línea
                    ),
                    SizedBox(height: 4),
                    if (playlistName != '')
                      Text(
                        playlistName,
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    SizedBox(height: 4),
                    Text(
                      '$_direction: ${widget.group.Direction}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupEdit(group: widget.group),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor.replaceAll("#", ""), radix: 16) + 0xFF000000);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_deleteGroup),
          content: Text(_sureDeleteGroup),
          actions: <Widget>[
            TextButton(
              child: Text(_cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                _delete,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _deleteGroupByName(widget.group.Name.toString());
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
  void _deleteGroupByName(String groupName) {
    FirebaseFirestore.instance
        .collection("Group")
        .where("Name", isEqualTo: groupName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete().then((value) {
          print("Grupo eliminado: $groupName");
          updateAppointsAfterGroupDeletion(doc.id);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GroupListScreen()),
          );
        }).catchError((error) => print("Error al eliminar grupo: $error"));
      });
    }).catchError((error) => print("Error al eliminar grupo: $error"));
  }

  void updateAppointsAfterGroupDeletion(String groupId) {
    FirebaseFirestore.instance
        .collection("Appoints")
        .where("Group", isEqualTo: groupId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({"Group": ""}).then((value) {
          print("Campo 'Group' actualizado a vacío para el Appoint con ID: ${doc.id}");
        }).catchError((error) => print("Error al actualizar Appoint: $error"));
      });
    }).catchError((error) => print("Error al buscar Appoints: $error"));
  }
}
