import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Calendarios/Pagina Principal.dart';
import '../Init/Register.dart';
import '../UserControll/Forgot Password.dart';
import '../components/my_textfield.dart';
import '../components/initial_logo.dart';
import '../components/less_important_button.dart';
import '../services/Auth.dart';
import '../text_displays/h1_title.dart';
import 'dart:ui' as ui;


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //TRADUCCIONES
  late String _welcomeBack = "";
  late String _email = "";
  late String _password = "";
  late String _loginT = "";
  late String _keepmelogged = "";
  late String _signInGoogle = "";
  late String _forgot = "";
  late String _signUp = "";



  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _welcomeBack = translations['welcomeBack'] ?? "";
      _email = translations['email'] ?? "";
      _password = translations['password'] ?? "";
      _loginT = translations['loginT'] ?? "";
      _keepmelogged = translations['keepmelogged'] ?? "";
      _signInGoogle = translations['signInGoogle'] ?? "";
      _forgot = translations['forgot'] ?? "";
      _signUp = translations['signUp'] ?? "";
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
  ////////////////////////////////////////////////////////
  MyTextField email = MyTextField(
    controller: TextEditingController(),
    hintText: "",
    title: "Email",
    obscureText: false,
    keyboardType: TextInputType.emailAddress,
  );
  MyTextField password = MyTextField(
    controller: TextEditingController(),
    hintText: "",
    title: 'Password',
    obscureText: true,
    keyboardType: TextInputType.text,
  );
  H1Title title = const H1Title(text: 'Welcome back!');
  LessImportantButton forgot = LessImportantButton(text: "Forgot password", route: ForgotPasswordScreen());
  LessImportantButton signUp = LessImportantButton(text: "Sign Up", route: const CreateAccount());
  bool? keepLoggedIn;
  bool isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              const InitialLogo(),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: title,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(child: email),
              const SizedBox(height: 15.0),
              SizedBox(child: password),
              CheckboxListTile(
                title:  Text("Keep me logged in",style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400)),
                value: keepLoggedIn ?? false,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFFB8CBE2),
                onChanged: _toggleKeepLoggedIn,
              ),

              ElevatedButton(
                onPressed: isButtonEnabled ? () => login() : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 125.0),
                  elevation: 0,
                  backgroundColor: const Color(0xFFB8CBE2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                ),

                child: Text("LOGIN", style: TextStyle(
              color: isButtonEnabled ? Colors.black : Colors.grey,),
              ),),
              const SizedBox(height: 10.0),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                child: ElevatedButton(
                  onPressed: () => _signInWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24 // Color para modo oscuro
                      : Colors.black, // Color para modo claro
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Add rounded corners with 10px radius
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 15.0), // Adjust horizontal padding if needed
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
                    children: [
                      Image.asset(
                        'assets/google_icon.png',
                        height: 25,
                      ),
                      const SizedBox(width: 10), // Add horizontal spacing
                       Text(
                        _signInGoogle,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [forgot, signUp],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleKeepLoggedIn(bool? value) {
    setState(() {
      keepLoggedIn = value;
    });
  }

  void login() async {
    final message = await AuthService().loginWithEmail(
      email: email.controller.text,
      password: password.controller.text,
    );
    if (message!.contains('Success')) {
      bool isEmailVerified = AuthService().isEmailVerified();
      if (isEmailVerified) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('loggedInUser', FirebaseAuth.instance.currentUser!.uid);
        prefs.setBool('keepLoggedIn', keepLoggedIn!); // Guardar preferencia

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }
  void _signInWithGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final userCredential = await AuthService().signInWithGoogle();
      print('Signed in with Google: ${userCredential.user!.displayName}');
      prefs.setBool('keepLoggedIn', keepLoggedIn!); // Guardar preferencia
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = isLoginReady(email.controller.text, password.controller.text);
    });
  }

  bool isLoginReady(String email, String password) {
    return email.isNotEmpty && password.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    loadTranslations();
    _loadSavedLocale();
    email.controller.addListener(_updateButtonState);
    password.controller.addListener(_updateButtonState);
    _loadKeepLoggedIn();
  }

  void _loadKeepLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;
    });
  }

  @override
  void dispose() {
    email.controller.removeListener(_updateButtonState);
    password.controller.removeListener(_updateButtonState);
    super.dispose();
  }
}
