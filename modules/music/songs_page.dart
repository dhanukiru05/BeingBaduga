import 'package:beingbaduga/modules/music/MusicPlayerPage.dart';
import 'package:beingbaduga/modules/music/music_models.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatelessWidget {
  final Album album;
  final Artist artist;

  SongsPage({required this.album, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${album.albumName} Songs'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SongSearchDelegate(
                  allSongs: album.songs,
                  artist: artist,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Album Image with Gradient and Album Name
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(
                    album.albumImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  album.albumName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                  onPressed: () {
                    // Handle play button action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerPage(
                          songs: album.songs,
                          artist: artist,
                          initialIndex: 0, // Start playing from the first song
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                right: 70,
                child: IconButton(
                  icon: Icon(Icons.shuffle, color: Colors.white, size: 30),
                  onPressed: () {
                    // Handle shuffle action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerPage(
                          songs: List<Song>.from(album.songs)
                            ..shuffle(), // Clone and shuffle the songs
                          artist: artist,
                          initialIndex: 0, // Start playing from the first song
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // List of Songs
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: album.songs.length,
              itemBuilder: (context, index) {
                final song = album.songs[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Song Image and Name
                      Row(
                        children: [
                          Image.network(
                            song.songImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 10),
                          Text(
                            song.songName,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      // Play Button
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          // Play the selected song
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MusicPlayerPage(
                                songs: album.songs,
                                artist: artist,
                                initialIndex: index, // Play the selected song
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SongSearchDelegate extends SearchDelegate<Song> {
  final List<Song> allSongs;
  final Artist artist;

  SongSearchDelegate({required this.allSongs, required this.artist});

  @override
  String get searchFieldLabel => 'Search songs';

  @override
  TextStyle? get searchFieldStyle => TextStyle(fontSize: 18);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, allSongs.first),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allSongs
        .where(
            (song) => song.songName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSongList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allSongs
        .where(
            (song) => song.songName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSongList(context, suggestions);
  }

  Widget _buildSongList(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) {
      return Center(
        child: Text(
          'No songs found.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Image.network(
            song.songImage,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(song.songName),
          trailing: IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayerPage(
                    songs: allSongs,
                    artist: artist,
                    initialIndex: allSongs.indexOf(song),
                  ),
                ),
              );
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerPage(
                  songs: allSongs,
                  artist: artist,
                  initialIndex: allSongs.indexOf(song),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
