import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

import '../Data/RehuseCommands.dart';

class ChangeNameScreen extends StatefulWidget {
  @override
  _ChangeNameScreenState createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen>{


  //Translations

  late String _changeName = "";
  late String _enterName = "";
  late String _newName = "";
  late String _changedSuccesfully = "";
  late String _errorName = "";

  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent =
    await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _changeName = translations['changeName'] ?? "";
      _enterName = translations['enterNewName'] ?? "";
      _newName = translations['newName'] ?? "";
      _changedSuccesfully = translations['changedSuccesfully'] ?? "";
      _errorName = translations['errorName'] ?? "";
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

  @override
  void initState() {
    super.initState();
    loadTranslations();
    _loadSavedLocale();
  }


  final _nameController = TextEditingController();
String _errorMessage = '';

@override
Widget build(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    appBar: AppBar(
      title: Text(_changeName),
    ),
    body: Padding(

      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            _enterName,
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
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
              hintText: _newName,
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.3),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            cursorColor: Colors.blue,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              changeName();
            },
            child: Text(_changeName, style: TextStyle(color:Colors.black)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 110.0),
              elevation: 0,
              backgroundColor: const Color(0xFFB8CBE2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<void> changeName() async {
  try {
    String? userId = await logedInUser();
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'name': _nameController.text.trim()});
      setState(() {
        _nameController.clear();
        _errorMessage = _changedSuccesfully;

      });
    }
  } catch (e) {
    print(e);
    setState(() {
      _errorMessage = _errorName;
    });
  }
}
}
