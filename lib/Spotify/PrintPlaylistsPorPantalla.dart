import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(PlaylistList_());

class PlaylistList_ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Playlists',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlaylistList(),
    );
  }
}

class PlaylistList extends StatefulWidget {
  @override
  _PlaylistListState createState() => _PlaylistListState();
}
class _PlaylistListState extends State<PlaylistList> {
  List<Map<String, dynamic>> playlists = [];
  String? selectedPlaylistId;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? acces_tocken = prefs.getString('access_token');
    final accessToken = acces_tocken;
    final url = Uri.parse('https://api.spotify.com/v1/me/playlists');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'];

      List<Map<String, dynamic>> playlistData = [];

      for (var item in items) {
        final playlistName = item['name'];
        String? imageUrl;
        if (item['images'] != null && item['images'].isNotEmpty) {
          imageUrl = item['images'][0]['url'];
        }
        final playlistId = item['id'];

        playlistData.add({
          'name': playlistName,
          'image': imageUrl,
          'id': playlistId,
        });
      }

      setState(() {
        playlists = playlistData;
        selectedPlaylistId = playlists.isNotEmpty ? playlists.first['id'] : null;
      });
    } else {
      print('Error al obtener las playlists: ${response.statusCode} ');
    }
  }

  Future<void> playPlaylist(String playlistId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? acces_tocken = prefs.getString('access_token');
    final accessToken = acces_tocken;
    final url = Uri.parse('https://open.spotify.com/playlist/$playlistId');

    if (await canLaunchUrl(url)) {
      await launch(
        url.toString(),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spotify Playlists'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final playlistName = playlist['name'];
                final imageUrl = playlist['image'];
                print(imageUrl);
                final playlistId = playlist['id'];
                print(playlistId);

                return ListTile(
                  onTap: () => playPlaylist(playlistId),
                  leading: imageUrl != null
                      ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.music_note),
                  ),
                  title: Text(playlistName),
                );
              },
            ),
          ),
          DropdownButton<String>(
            value: selectedPlaylistId,
            onChanged: (newValue) {
              setState(() {
                selectedPlaylistId = newValue;
              });
              // Call playPlaylist or any other function when dropdown value changes
            },
            items: playlists.map((playlist) {
              final playlistName = playlist['name'];
              final playlistId = playlist['id'];
              return DropdownMenuItem<String>(
                value: playlistId,
                child: Text(playlistName),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
