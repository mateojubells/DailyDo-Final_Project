import 'package:flutter/material.dart';

class LessImportantButton extends StatelessWidget {
  String text;
  StatefulWidget route;

  LessImportantButton({
    required this.text,
    required this.route,
    super.key
  });
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => route,
          ),
        );
      },
      child: Text(text,
          style: const TextStyle(color: Colors.grey)
      ),
    );
  }
}
