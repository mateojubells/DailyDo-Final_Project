import 'package:flutter/material.dart';

class H1Title extends StatelessWidget {
  final String text;

  const H1Title({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08), // Ajusta los márgenes laterales según el ancho de la pantalla
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w400,

          ),
        )
    );
  }
}
