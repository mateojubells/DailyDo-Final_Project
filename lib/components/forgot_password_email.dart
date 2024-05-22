import 'package:daily_doii/utils/checkTextFormat.dart';
import 'package:flutter/material.dart';

class ForgotPasswordEmail extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;

  const ForgotPasswordEmail({
    super.key,
    required this.controller,
    required this.hintText,
    required this.title,
  });

  @override
  State<ForgotPasswordEmail> createState() => _ForgotPasswordEmailState();
}

class _ForgotPasswordEmailState extends State<ForgotPasswordEmail> {
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

  void _onTextChanged(String text) {
    setState(() {
      _textFieldContent = text;
      _isValidEmail = checker.isValidEmailFormat(text);
      _displayErrorText = _getErrorText(text); // Verifica y actualiza el mensaje de error
    });
  }

  bool getEmailValid() {
    return _isValidEmail;
  }

  String _getErrorText(String text) {
    if (text.isEmpty) {
      return ''; // No muestra error si el campo está vacío
    }
    return _isValidEmail ? '' : 'Email not valid'; // Muestra error solo si el correo no es válido
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                cursorColor: Colors.blue,
                autocorrect: false,
                autofillHints: null,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.none,
                onChanged: _onTextChanged, // Usa la función para detectar cambios
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
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.3),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              if (!_isValidEmail && !_isFocused && _textFieldContent.length != 0)
                const Positioned(
                  right: 8,
                  child: Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          if (!_isValidEmail && !_isFocused && _textFieldContent.isNotEmpty) // Muestra el mensaje de error solo si hay texto y es inválido
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _displayErrorText,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
