import 'package:beingbaduga/modules/music/MusicPlayerPage.dart';
import 'package:flutter/material.dart';
import 'package:beingbaduga/modules/music/music_models.dart';

class AllSongsPage extends StatelessWidget {
  final List<Song> songs;
  final Artist artist;

  AllSongsPage({required this.songs, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Songs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: () {
              // Shuffle the list of songs and navigate to MusicPlayerPage
              List<Song> shuffledSongs = List<Song>.from(songs)..shuffle();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayerPage(
                    songs: shuffledSongs, // Pass the shuffled list of songs
                    artist: artist,
                    initialIndex:
                        0, // Start playing from the first shuffled song
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AllSongsSearchDelegate(
                  allSongs: songs,
                  artist: artist,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Album image with play button overlay
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200, // Adjust height as per your need
                child:
                    artist.artistImage != null && artist.artistImage!.isNotEmpty
                        ? Image.network(
                            artist.artistImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: Icon(
                                  Icons.music_note,
                                  size: 100,
                                  color: Colors.white70,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey,
                            child: Icon(
                              Icons.music_note,
                              size: 100,
                              color: Colors.white70,
                            ),
                          ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigate to MusicPlayerPage and start playing the first song
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerPage(
                          songs: songs, // Pass the list of songs
                          artist: artist,
                          initialIndex: 0, // Start playing from the first song
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.play_arrow, size: 30),
                ),
              ),
            ],
          ),
          // Container holding the list of songs
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                Song song = songs[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: song.songImage.isNotEmpty
                          ? Image.network(
                              song.songImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.music_note, size: 50);
                              },
                            )
                          : Icon(Icons.music_note, size: 50),
                    ),
                    title: Text(song.songName),
                    subtitle: Text(artist.artistName ?? 'Unknown Artist'),
                    trailing: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        // Navigate to MusicPlayerPage and pass the list of songs and current song index
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MusicPlayerPage(
                              songs:
                                  songs, // Use the list of songs passed to this page
                              artist: artist,
                              initialIndex:
                                  index, // Pass the index of the selected song
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Optional: You can handle tap on the entire ListTile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicPlayerPage(
                            songs: songs,
                            artist: artist,
                            initialIndex: index,
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
    );
  }
}

class AllSongsSearchDelegate extends SearchDelegate<Song> {
  final List<Song> allSongs;
  final Artist artist;

  AllSongsSearchDelegate({required this.allSongs, required this.artist});

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
        .where((song) =>
            song.songName.toLowerCase().contains(query.toLowerCase()) ||
            (artist.artistName != null &&
                artist.artistName!.toLowerCase().contains(query.toLowerCase())))
        .toList();

    return _buildSongList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allSongs
        .where((song) =>
            song.songName.toLowerCase().contains(query.toLowerCase()) ||
            (artist.artistName != null &&
                artist.artistName!.toLowerCase().contains(query.toLowerCase())))
        .toList();

    return _buildSongList(context, suggestions);
  }

  Widget _buildSongList(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No songs found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final songName = song.songName;
        final queryText = query.toLowerCase();
        final songNameLower = songName.toLowerCase();
        final startIndex = songNameLower.indexOf(queryText);

        TextSpan titleSpan;
        if (startIndex != -1) {
          titleSpan = TextSpan(
            text: songName.substring(0, startIndex),
            style: TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: songName.substring(startIndex, startIndex + query.length),
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: songName.substring(startIndex + query.length),
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          );
        } else {
          titleSpan = TextSpan(
            text: songName,
            style: TextStyle(color: Colors.black, fontSize: 16),
          );
        }

        return ListTile(
          leading: song.songImage.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    song.songImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.music_note, size: 50);
                    },
                  ),
                )
              : Icon(Icons.music_note, size: 50),
          title: RichText(
            text: titleSpan,
          ),
          subtitle: Text(artist.artistName ?? 'Unknown Artist'),
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
