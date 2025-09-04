// lib/AllSongsPage.dart
import 'dart:ui';
import 'package:beingbaduga/modules/AUDIO/audio_manager.dart';
import 'package:beingbaduga/modules/AUDIO/bottom_player_bar.dart';
import 'package:beingbaduga/modules/AUDIO/music_model.dart';
import 'package:beingbaduga/modules/AUDIO/player.dart';
import 'package:flutter/material.dart';

class AllSongsPage extends StatefulWidget {
  final List<Artist> artists;

  AllSongsPage({required this.artists});

  @override
  _AllSongsPageState createState() => _AllSongsPageState();
}

class _AllSongsPageState extends State<AllSongsPage> {
  TextEditingController _searchController = TextEditingController();
  List<Song> filteredSongs = [];
  final AudioManager audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSongs);
    filteredSongs = _getAllSongs();
  }

  List<Song> _getAllSongs() {
    List<Song> songs = [];
    for (var artist in widget.artists) {
      for (var album in artist.albums) {
        songs.addAll(album.songs);
      }
    }
    return songs;
  }

  void _filterSongs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredSongs = _getAllSongs()
          .where((song) => song.songName.toLowerCase().contains(query))
          .toList();
    });
  }

  String getArtistNameBySong(Song song) {
    for (var artist in widget.artists) {
      for (var album in artist.albums) {
        if (album.songs.contains(song)) {
          return artist.artistName;
        }
      }
    }
    return 'Unknown Artist';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Songs'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackgroundImage(context),
          _buildGlassyOverlay(context),
          Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: filteredSongs.isEmpty
                    ? Center(
                        child: Text(
                          'No songs available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.play_circle_fill,
                                  color: Colors.white),
                              title: Text(
                                song.songName,
                                style: TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                song.artistName ?? 'Unknown Artist',
                                style: TextStyle(color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MusicPlayerPage(
                                      song: song,
                                      playlist: filteredSongs,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomPlayerBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://res.cloudinary.com/dyjx95lts/image/upload/v1751969308/gbsfm8sjaes9qjfaavgj.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGlassyOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search Songs',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

extension on Object? {
  get songName => null;
}
