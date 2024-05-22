import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class ChangeEmailScreen extends StatefulWidget {
  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  //Translations
  late String _changeEmail = "";
  late String _enterNewEmailAddress = "";
  late String _newEmail = "";
  late String _changedSuccessfully = "";
  late String _errorEmail = "";

  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent =
    await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _changeEmail = translations['changeEmail'] ?? "";
      _enterNewEmailAddress = translations['enterNewEmailAddress'] ?? "";
      _newEmail = translations['newEmail'] ?? "";
      _changedSuccessfully = translations['changedSuccessfully'] ?? "";
      _errorEmail = translations['errorEmail'] ?? "";
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

  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_changeEmail),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              _enterNewEmailAddress,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
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
                hintText: _newEmail,
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
                changeEmail();
              },
              child: Text(_changeEmail, style: TextStyle(color:Colors.black)),
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

  Future<void> changeEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        setState(() {
          _emailController.clear();
          _errorMessage = _changedSuccessfully;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage = '$_errorEmail: $e';
      });
    }
  }
}
