import 'dart:convert';
import 'package:daily_doii/utils/checkTextFormat.dart';
import 'package:flutter/material.dart';
import 'package:daily_doii/services/Auth.dart';
import 'package:daily_doii/components/names_textField.dart';
import 'package:daily_doii/components/email_textfield.dart';
import 'package:daily_doii/components/check_signup.dart';
import 'package:daily_doii/components/password_field.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  // TRADUCCIONES
  late String _name = "";
  late String _nameInput = "";
  late String _email = "";
  late String _emailInput = "";
  late String _password = "";
  late String _passwordinput = "";
  late String _repPassword = "";
  late String _repPasswordInput = "";
  late String _registrar = "";

  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();

  Future<void> loadTranslations() async {
    String locale = ui.window.locale.languageCode;
    String jsonContent = await rootBundle.loadString('lib/l10n/app_$locale.arb');
    Map<String, dynamic> translations = json.decode(jsonContent);
    _updateTranslations(translations);
  }

  void _updateTranslations(Map<String, dynamic> translations) {
    setState(() {
      _name = translations['name'] ?? "";
      _nameInput = translations['nameInput'] ?? "";
      _email = translations['email'] ?? "";
      _emailInput = translations['emailInput'] ?? "";
      _password = translations['password'] ?? "";
      _passwordinput = translations['passwordinput'] ?? "";
      _repPassword = translations['repPassword'] ?? "";
      _repPasswordInput = translations['repPasswordInput'] ?? "";
      _registrar = translations['registrar'] ?? "";
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

  EmailTextField email = EmailTextField(
    controller: TextEditingController(),
    hintText: "Enter your email",
    title: "Email",
  );
  PasswordField password = PasswordField(
    controller: TextEditingController(),
    hintText: "Enter your password",
    title: "Password",
    obscureText: true,
  );
  PasswordField repeatPassword = PasswordField(
    controller: TextEditingController(),
    hintText: "Repeat your password",
    title: "Repeat password",
    obscureText: true,
  );
  NameTextField name = NameTextField(
    controller: TextEditingController(),
    hintText: "Enter your name",
    title: "Name",
  );

  bool isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            name,
            const SizedBox(height: 10.0),
            email,
            const SizedBox(height: 10.0),
            password,
            const SizedBox(height: 10.0),
            repeatPassword,
            const SizedBox(height: 15.0),
            PasswordCheck(
              passwordController: password.controller,
              repeatPasswordController: repeatPassword.controller,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isButtonEnabled ? () => _register() : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 110.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                backgroundColor: const Color(0xFFB8CBE2),
              ),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }

  void _register() async {
    final message = await AuthService().signUpWithEmail(
      name: name.controller.text,
      email: email.controller.text,
      password: password.controller.text,

    );
    _clearFields();

    if (message != null && message.contains('Success')) {
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'An error occurred'),
        ),
      );
    }
  }

  void _clearFields() {
    setState(() {
      name.controller.clear();
      email.controller.clear();
      password.controller.clear();
      repeatPassword.controller.clear();
    });
  }

  void _updateButtonState() {
    CheckTextFormat checker = CheckTextFormat();
    setState(() {
      bool correctName = checker.isValidCharacterFormat(name.controller.text);
      bool correctEmail = checker.isValidEmailFormat(email.controller.text);
      bool correctPassword = checker.isValidPasswordFormat(password.controller.text);
      bool correctRepeatPassword = checker.isRepeatPasswordCorrect(
          repeatPassword.controller.text, password.controller.text);

      isButtonEnabled = correctName && correctEmail && correctPassword && correctRepeatPassword;
    });
  }

  @override
  void initState() {
    super.initState();
    email.controller.addListener(_updateButtonState);
    name.controller.addListener(_updateButtonState);
    password.controller.addListener(_updateButtonState);
    repeatPassword.controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    email.controller.removeListener(_updateButtonState);
    name.controller.removeListener(_updateButtonState);
    password.controller.removeListener(_updateButtonState);
    repeatPassword.controller.removeListener(_updateButtonState);
    super.dispose();
  }
}
