import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;
  final bool obscureText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.title,
    required this.obscureText,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {

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
          TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            cursorColor: Colors.blue,
            onChanged: (text) {
              // Puedes agregar aquí cualquier acción adicional que desees realizar cuando cambie el texto
            },
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Ajuste del tamaño del campo de texto
            ),
            textInputAction: TextInputAction.none,
          ),
        ],
      ),
    );
  }
}
