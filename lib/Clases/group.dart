import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String? id; // Nuevo campo para almacenar el ID del documento en Firestore
  String? Name;
  String? Color;
  String? Direction;
  String? Playlist;

  Group({
    this.id, // Agregamos el ID al constructor
    this.Name,
    this.Color,
    this.Direction,
    this.Playlist,
  });

  // Método para convertir un documento de Firestore a un objeto Group
  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      Name: data['Name'],
      Color: data['Color'],
      Direction: data['Direction'],
      Playlist: data['Playlist'],
    );
  }
}
