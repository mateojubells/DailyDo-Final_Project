import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String loggedInUser;


  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('loggedInUser', _auth.currentUser!.uid);
      syncUserEmail();
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();
      await _saveUserToDatabase(userCredential.user!.uid, name, email);

      return 'Check your email to verify your account';

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _saveUserToDatabase(String userId, String name,
      String email) async {
    try {
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDocs.docs.isNotEmpty) {
        // Si el usuario ya existe en la base de datos, obtén su ID
        loggedInUser = userDocs.docs.first.id;
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(
            userId) // Utiliza el ID de usuario autenticado como ID de documento
            .set({'name': name, 'email': email});
        loggedInUser = userId;
      }

      // Guarda el ID del usuario en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('loggedInUser', loggedInUser);
      print("Este es el ID del usuario: $loggedInUser");
    } catch (e) {
      print('Error saving user to database: $e');
      throw e;
    }
  }


  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loggedInUser');
    prefs.remove('keepLoggedIn');
    prefs.remove('access_token');
    prefs.remove('refresh_token');
    prefs.remove('locale');

    await _auth.signOut();
    return true;
  }

  bool isEmailVerified() {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.emailVerified;
    }
    return false;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // Save user to database
      await _saveUserToDatabase(
        userCredential.user!.uid,
        userCredential.user!.displayName ?? 'User',
        userCredential.user!.email ?? '',
      );

      return userCredential;
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }


  Future<void> changePassword(String newPassword) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? _token2 = sharedPreferences.getString("token");
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyCFisC4VQD9u1N_K_Kj78qypS6nELDqk6U';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'idToken': _token2,
            'password': newPassword,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("Password changed successfully");
      } else {
        // Handle error
        print("Error changing password: ${responseData['error']['message']}");
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> syncUserEmail() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final authEmail = currentUser.email;
      final dbEmail = await getUserEmailFromDatabase(currentUser.uid);
      if (dbEmail != authEmail) {
        await updateUserEmailInDatabase(currentUser.uid, authEmail!);
      }
    }
  }

  Future<String?> getUserEmailFromDatabase(String userId) async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['email'];
      }
      return null;
    } catch (e) {
      print('Error getting user email from database: $e');
      throw e;
    }
  }

  Future<void> updateUserEmailInDatabase(String userId, String newEmail) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'email': newEmail}, SetOptions(merge: true));
    } catch (e) {
      print('Error updating email in database: $e');
      throw e;
    }
  }
}