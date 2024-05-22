import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;
  final bool obscureText;
  final TextInputType keyboardType;


  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.title,
    required this.obscureText,
    required this.keyboardType,
  }) : super(key: key);

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
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                title,
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
            controller: controller,
            obscureText: obscureText,
            cursorColor: Colors.blue,
            keyboardType: keyboardType,
            onChanged: (text) {
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
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.3),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            textInputAction: TextInputAction.none,
          ),
        ],
      ),
    );
  }
}
