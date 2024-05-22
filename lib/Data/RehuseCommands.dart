import 'package:shared_preferences/shared_preferences.dart';


Future<String?> logedInUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('loggedInUser');
  return userId;
}