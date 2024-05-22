import 'package:daily_doii/utils/checkTextFormat.dart';
import 'package:flutter/material.dart';

class EmailTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;

  const EmailTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.title,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  String _textFieldContent = '';
  bool _isValidEmail = true;
  String _displayErrorText = '';
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  CheckTextFormat checker = CheckTextFormat();


  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFFACB5BD),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                cursorColor: Colors.blue,
                keyboardType: TextInputType.emailAddress,
                autofillHints: null,
                onChanged: (text) {
                  setState(() {
                    _textFieldContent = text;
                    _isValidEmail = checker.isValidEmailFormat(text);
                    _displayErrorText = _getErrorText(text);
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isValidEmail
                          ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.black  // Si el correo es válido y el modo es oscuro
                          : Colors.grey)  // Si el correo es válido y el modo es claro
                          : Colors.red,  // Siempre rojo cuando el correo es inválido
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: isDarkMode ? Colors.white24 : Colors.white,
                  filled: true,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.3),
                    fontWeight: FontWeight.w300,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                textInputAction: TextInputAction.none, // Desactiva la sugerencia de direcciones de correo electrónico
              ),
              if (!_isValidEmail && !_isFocused)
                const Positioned(
                  right: 8,
                  child: Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          if (!_isValidEmail && !_isFocused)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 0),
              child: Text(
                _displayErrorText,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }


  String _getErrorText(String text) {
    if (text.isEmpty) {
      return 'Email required';
    } else if (text.length > 100) {
      return 'Max: 100 characters';
    } else {
      return 'Email not valid';
    }
  }
}
