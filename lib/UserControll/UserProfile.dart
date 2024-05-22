import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../Init/menuDesplegable.dart';
import '../Spotify/SpotifyLogin.dart';
import 'ChangeEmail.dart';
import 'dart:ui' as ui;


import 'ChangeUserName.dart';

class UserView extends StatefulWidget {
  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  late String _appTitle = "";
  late String _nameLabel = "";
  late String _emailLabel = "";
  late String _changeEmail = "";
  late String _changeName = "";
  late String _cancelButton = "";
  late String _logoutButton = "";
  late String _loginSpotify = "";
  late String _logoutSpotify = "";
  late String _logoutConfirmationTitle = "";
  late String _logoutConfirmationContent = "";

  bool isTodaySelected = false;
  bool isWeekSelected = false;
  bool isMonthSelected = false;
  bool isWeeklySelected = false;
  bool isGroupSelected = false;
  bool isSettingsSelected = true;

  File? _imageFile;
  String? _profileImageUrl;
  late Future<String?> _userIdFuture;

  @override
  void initState() {
    super.initState();
    _userIdFuture = getUserId();
    _loadProfileImageUrl();
    loadTranslations();
    _loadSavedLocale();
  }

  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _appTitle = translations['appTitle'] ?? "";
      _nameLabel = translations['nameLabel'] ?? "";
      _emailLabel = translations['emailLabel'] ?? "";
      _cancelButton = translations['cancelButton'] ?? "";
      _changeName = translations['changeName'] ?? "";
      _changeEmail = translations['changeEmail'] ?? "";
      _logoutButton = translations['logoutButton'] ?? "";
      _loginSpotify = translations['loginSpotify'] ?? "";
      _logoutSpotify = translations['logoutSpotify'] ?? "";
      _logoutConfirmationTitle = translations['logoutConfirmationTitle'] ?? "";
      _logoutConfirmationContent = translations['logoutConfirmationContent'] ?? "";
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

  // Métodos para cambiar el idioma a inglés, español y catalán
  void _switchToEnglish() async {
    await loadTranslationsForLocale('en');
    _saveLocale('en');
  }

  void _switchToSpanish() async {
    await loadTranslationsForLocale('es');
    _saveLocale('es');
  }

  void _switchToCatalan() async {
    await loadTranslationsForLocale('ca');
    _saveLocale('ca');
  }

  Future<void> _saveLocale(String locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  Future<void> _loadProfileImageUrl() async {
    final userId = await getUserId();
    if (userId != null) {
      final snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = snapshot.data();
      setState(() {
        _profileImageUrl = data?['profileImageUrl'];
      });
    }
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('loggedInUser');
    return loggedInUserId;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      final imageUrl = await _uploadImageToStorage(_imageFile!);

      await _saveImageToFirestore(imageUrl!);
    }
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final userId = await getUserId();
      if (userId != null) {
        final firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$userId.jpg'); // Cambio en la ruta del archivo
        await firebaseStorageRef.putFile(imageFile);
        final downloadUrl = await firebaseStorageRef.getDownloadURL();
        return downloadUrl;
      } else {
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveImageToFirestore(String imageUrl) async {
    try {
      final userId = await getUserId();
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profileImageUrl': imageUrl});
      }
    } catch (e) {
      print('Error saving image to Firestore: $e');
    }
  }

  Widget _buildProfileImageWidget(DocumentSnapshot snapshot) {
    if (_imageFile != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_imageFile!),
      );
    } else if (_profileImageUrl != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_profileImageUrl!),
      );
    } else {
      var userData = snapshot.data() as Map<String, dynamic>;
      String? name = userData['name'];
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=${name}"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appTitle),
      ),
      drawer: CustomDrawer(
        isTodaySelected: isTodaySelected,
        isWeekSelected: isWeekSelected,
        isMonthSelected: isMonthSelected,
        isWeeklySelected: isWeeklySelected,
        isGroupSelected: isGroupSelected,
        isSettingsSelected: isSettingsSelected
      ),
      body: FutureBuilder<String?>(
        future: _userIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showImagePicker(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: _buildProfileImageWidget(snapshot.data!),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$_nameLabel', style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w200)),
                              Text(' ${snapshot.data!['name']}', style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w400) )
                            ],
                          ),

                          SizedBox(height: 10),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$_emailLabel', style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w200)),
                              Text(' ${snapshot.data!['email']}', style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w400) )
                            ],
                          ),

                          SizedBox(height: 30),

                          Divider(),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChangeNameScreen()),
                              );
                              await _refreshUserData();
                            },
                            child: ListTile(
                              title: Text(_changeName, style: TextStyle(fontWeight: FontWeight.w300)), // Cambio el texto aquí
                              leading: Icon(Icons.badge),
                            ),                          ),

                          Divider(),
                          ListTile(
                            title: Text('$_changeEmail', style: TextStyle(fontWeight: FontWeight.w300)),
                            leading: Icon(Icons.email_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChangeEmailScreen()),
                              );
                            },
                          ),

                          Divider(),
                          ListTile(
                            leading: Image.asset(
                              'assets/images/spotify.png',
                              width: 24, // Tamaño deseado del logo
                              height: 24,
                            ),
                            title: Text('$_loginSpotify', style: TextStyle(fontWeight: FontWeight.w300)),
                            onTap: () async {
                              await RemoteService();
                              Navigator.pop(context);
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text('$_logoutSpotify', style: TextStyle(fontWeight: FontWeight.w300, color: Colors.redAccent)),
                            leading: Icon(Icons.music_off, color: Colors.redAccent),
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('$_logoutConfirmationTitle'),
                                    content: Text('$_logoutConfirmationContent'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(_cancelButton),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                                        },
                                      ),
                                      TextButton(
                                        child: Text(_logoutButton),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await cerrarSesion();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Row(
                                  children: [
                                    Icon(Icons.language),
                                    SizedBox(width: 5),
                                    Text('EN'),
                                  ],
                                ),
                                onPressed: _switchToEnglish,
                                tooltip: 'Switch to English',
                              ),
                              IconButton(
                                icon: Row(
                                  children: [
                                    Icon(Icons.language),
                                    SizedBox(width: 5),
                                    Text('ES'), // Siglas del idioma
                                  ],
                                ),
                                onPressed: _switchToSpanish,
                                tooltip: 'Cambiar a español',
                              ),
                              IconButton(
                                icon: Row(
                                  children: [
                                    Icon(Icons.language),
                                    SizedBox(width: 5),
                                    Text('CA'), // Siglas del idioma
                                  ],
                                ),
                                onPressed: _switchToCatalan,
                                tooltip: 'Canviar a català',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _refreshUserData() async {
    final userId = await getUserId();
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final data = snapshot.data();
      setState(() {
        _profileImageUrl = data?['profileImageUrl'];
        _nameLabel = data?['name'];
      });
    }
  }



  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera_rounded),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded),
                title: Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
