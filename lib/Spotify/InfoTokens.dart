import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(InfotTokens());
}

class InfotTokens extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SharedPreferences Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InfoTokens(),
    );
  }
}

class InfoTokens extends StatefulWidget {
  @override
  _InfoTokensState createState() => _InfoTokensState();
}

class _InfoTokensState extends State<InfoTokens> {
  String? accessToken;
  String? refreshToken;

  @override
  void initState() {
    super.initState();
    getTokensFromSharedPreferences();
  }

  Future<void> getTokensFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('access_token');
      refreshToken = prefs.getString('refresh_token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SharedPreferences Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Access Token:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '$accessToken',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Refresh Token:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '$refreshToken',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
