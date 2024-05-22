import 'package:flutter/material.dart';

class InitialLogo extends StatelessWidget {
  const InitialLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 70),
        Icon(Icons.lock, size: 100),
      ],
    );
  }
}
