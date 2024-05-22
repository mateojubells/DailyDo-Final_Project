import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_doii/Spotify/CustomStrings.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


import '../UserControll/UserProfile.dart';


String? Access_Token;
String? Refresh_Token;

Future<void> RemoteService() async {
  AccessTokenResponse? accessToken;
  SpotifyOAuth2Client client = SpotifyOAuth2Client(
    customUriScheme: 'dailydoii',
    redirectUri: 'dailydoii://callback',
  );
  var authResp = await client.requestAuthorization(
      clientId: CustomStrings.clientId,
      customParams: {'show_dialog': 'true'},
      scopes: ['user-read-private', 'user-read-playback-state', 'user-modify-playback-state', 'user-read-currently-playing', 'user-read-email']
  );
  var authCode = authResp.code;
  print("El acces token es $authCode");
  accessToken = await client.requestAccessToken(code: authCode.toString(),
      clientId: CustomStrings.clientId,
      clientSecret: CustomStrings.secretId);
  print(accessToken.expirationDate);

  print(accessToken.expiresIn);

// Guardar en SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', accessToken?.accessToken ?? '');
  await prefs.setString('refresh_token', accessToken?.refreshToken ?? '');
  await prefs.setString('access_token_expiration', accessToken.expirationDate.toString());

print(accessToken.expirationDate.toString());
// Asignar valores a las variables globales
  Access_Token = accessToken?.accessToken;
  Refresh_Token = accessToken?.refreshToken;

  print("AccessToken: $Access_Token");
  print("RefreshToken: $Refresh_Token");
  print("Access Token guardado en SharedPreferences: $Access_Token");
  print("Refresh Token guardado en SharedPreferences: $Refresh_Token");
}

String? NewAccess_Token;
String? NewRefresh_Token;

Future<void> RefreshAccesToken() async {
  AccessTokenResponse? NewAccessToken;
  SpotifyOAuth2Client client = SpotifyOAuth2Client(
    customUriScheme: 'dailydoii',
    redirectUri: 'dailydoii://callback',
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString('refresh_token');
  if (refreshToken == null) {
    print("No se encontró un refreshToken en SharedPreferences.");
    return;
  }
  try {
    NewAccessToken = await client.refreshToken(
      refreshToken,
      clientId: CustomStrings.clientId,
      clientSecret: CustomStrings.secretId,
    );
    String fechaFinal = NewAccessToken.expirationDate.toString();
    print("La fecha de expiracion es $fechaFinal");
    prefs.setString("access_token_expiration", fechaFinal.toString());

    await prefs.setString('access_token', NewAccessToken?.accessToken ?? '');
    NewAccess_Token = NewAccessToken?.accessToken;
    print("Nuevo AccessToken: $NewAccess_Token");
    print("Access Token guardado en SharedPreferences: $NewAccess_Token");


  } catch (e) {
    print("Error al renovar AccessToken: $e");
  }
}
void CheckTokenExpiration() async {
  print("testing");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var expirationDateStr = prefs.getString('access_token_expiration');
print(expirationDateStr);
  if (expirationDateStr != null) {
    var expirationDate = DateTime.parse(expirationDateStr);
    var difference = expirationDate.difference(DateTime.now());

    if (difference.inMinutes <= 10 || difference.isNegative) {
      await RefreshAccesToken();
    } else {
      print("Tiempo restante para que caduque el token:");
      print("Minutos: ${difference.inMinutes % 60}");
      print("Segundos: ${difference.inSeconds % 60}");
    }
  }
}

Future<void> cerrarSesion() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', "");
  await prefs.setString('refresh_token', "");
  Access_Token = null;
  Refresh_Token = null;

  String? accesToken2 = prefs.getString('access_token');
  String? RefreshRToken2 = prefs.getString('refresh_token');
  print("Acces token: $accesToken2");
  print("Refresh token: $RefreshRToken2");

  print("Sesión cerrada. Tokens eliminados.");
}





