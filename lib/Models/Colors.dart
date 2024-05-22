import 'package:flutter/material.dart';

enum BasicColor {
  red,
  blue,
  yellow,
  green,
  orange,
  purple,
  brown,
  pink,
}

class ColorsHelper {
   static Color getColorFromEnum(BasicColor color) {
    switch (color) {
      case BasicColor.red:
        return Colors.red;
      case BasicColor.blue:
        return Colors.blue;
      case BasicColor.yellow:
        return Colors.yellow;
      case BasicColor.green:
        return Colors.green;
      case BasicColor.orange:
        return Colors.orange;
      case BasicColor.purple:
        return Colors.purple;
      case BasicColor.brown:
        return Colors.brown;
      case BasicColor.pink:
        return Colors.pink;
      default:
        return Colors.black;
    }
  }
   static BasicColor getColorBasic(Color color) {
     if (color == Colors.red) {
       return BasicColor.red;
     } else if (color == Colors.blue) {
       return BasicColor.blue;
     } else if (color == Colors.yellow) {
       return BasicColor.yellow;
     } else if (color == Colors.green) {
       return BasicColor.green;
     } else if (color == Colors.orange) {
       return BasicColor.orange;
     } else if (color == Colors.purple) {
       return BasicColor.purple;
     } else if (color == Colors.brown) {
       return BasicColor.brown;
     } else if (color == Colors.pink) {
       return BasicColor.pink;
     } else {
       return BasicColor.blue;
     }
   }


   static Color getColorFromName(String? colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.black;
    }
  }

   static BasicColor getBasicColorFromHex(String hexColor) {
     switch (hexColor.toUpperCase()) {
       case "#0000FF":
         return BasicColor.blue;
       case "#FF0000":
         return BasicColor.red;
       case "#00FF00":
         return BasicColor.green;
       case "#800080":
         return BasicColor.purple;
       case "#FF007F":
         return BasicColor.pink;
       case "#A52A2A":
         return BasicColor.brown;
       case "#FFA500":
         return BasicColor.orange;
       case "#EBDD22":
         return BasicColor.yellow;
       default:
         return BasicColor.blue;
     }
   }
}



