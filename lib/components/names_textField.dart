import 'package:daily_doii/utils/checkTextFormat.dart';
import 'package:flutter/material.dart';

class NameTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;

  const NameTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.title,
  });

  @override
  State<NameTextField> createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  String _textFieldContent = '';
  bool _isValidText = true;
  String displayErrorText = '';

  CheckTextFormat checker = CheckTextFormat();

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
                  fontWeight: FontWeight.w400, // Fuente más fina
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
                cursorColor: Colors.blue,
                onChanged: (text) {
                  setState(() {
                    _textFieldContent = text;
                    _isValidText = checker.isValidTextFormat(text);
                    displayErrorText = errorText(text);
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isValidText
                          ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.black  // Si el texto es válido y el modo es oscuro
                          : Colors.grey)  // Si el texto es válido y el modo es claro
                          : Colors.red,  // Siempre rojo cuando el texto es inválido
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Ajuste del tamaño del campo de texto
                ),
                textInputAction: TextInputAction.none,
              ),
              if (!_isValidText)
                const Positioned(
                  right: 8,
                  child: Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          if (!_isValidText)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                displayErrorText,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  String errorText(String text) {
    if (text.isEmpty) {
      return "Name required";
    } else {
      if (!checker.isValidTextFormat(text)) {
        return "Special characters and numbers not allowed";
      } else if (text.length >= 30) {
        return "Max: 30 characters";
      } else {
        return "";
      }
    }
  }
}
