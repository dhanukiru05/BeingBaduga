// lib/MusicPage.dart
import 'dart:convert';
import 'dart:ui';
import 'package:beingbaduga/User_Model.dart'; // Import the User model
import 'package:beingbaduga/modules/AUDIO/AlbumSongsPage.dart';
import 'package:beingbaduga/modules/AUDIO/AllAlbumsPage.dart';
import 'package:beingbaduga/modules/AUDIO/AllArtistsPage.dart';
import 'package:beingbaduga/modules/AUDIO/AllSongsPage.dart';
import 'package:beingbaduga/modules/AUDIO/ArtistAlbumsPage.dart';
import 'package:beingbaduga/modules/AUDIO/audio_manager.dart';
import 'package:beingbaduga/modules/AUDIO/bottom_player_bar.dart';
import 'package:beingbaduga/modules/AUDIO/music.dart';
import 'package:beingbaduga/modules/AUDIO/music_model.dart';
import 'package:beingbaduga/modules/AUDIO/player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MusicPage extends StatefulWidget {
  final User user;

  MusicPage({required this.user});

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<Artist> artists = [];
  bool isLoading = true;
  String errorMessage = '';

  final AudioManager audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      await fetchAllData();
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAllData() async {
    final url = 'https://beingbaduga.com/being_baduga/album.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Artist> fetchedArtists = [];
        List<Song> allSongs = [];
        for (var artistJson in data) {
          final artist = Artist.fromJson(artistJson);
          fetchedArtists.add(artist);
          for (var album in artist.albums) {
            for (var song in album.songs) {
              song.artistName = artist.artistName;
              allSongs.add(song);
            }
          }
        }

        setState(() {
          artists = fetchedArtists;
        });

        audioManager.setPlaylist(allSongs);
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'Resource not found (404). Please check the URL.';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        errorMessage = 'An error occurred while fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Music Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackgroundImage(context),
          _buildGlassyOverlay(context),
          _buildContent(context),
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

  Widget _buildContent(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load data:',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      _buildGreeting(context),
                      SizedBox(height: 10),
                      _buildWelcomeMessage(context),
                      SizedBox(height: 20),
                      _buildSectionHeader(context, "Albums You May Like",
                          onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AllAlbumsPage(artists: artists)),
                        );
                      }),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildAlbumCarousel(context),
                      ),
                      SizedBox(height: 20),
                      _buildSectionHeader(context, "Artists You May Like",
                          onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AllArtistsPage(artists: artists)),
                        );
                      }),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildArtistList(context),
                      ),
                      SizedBox(height: 20),
                      _buildSectionHeader(context, "Songs You May Like",
                          onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AllSongsPage(artists: artists)),
                        );
                      }),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildSongList(context),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
  }

  Widget _buildGreeting(BuildContext context) {
    return Text(
      "Good Morning, ${widget.user.name}",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
            fontSize: 16,
          ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Text(
      "Music World",
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {void Function()? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            "See All",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumCarousel(BuildContext context) {
    List<Album> albums = [];
    for (var artist in artists) {
      albums.addAll(artist.albums);
    }
    if (albums.isEmpty) {
      return Center(
        child: Text(
          'No albums available',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Container(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlbumSongsPage(album: album),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          album.albumImage,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey,
                              child: Icon(Icons.music_note,
                                  color: Colors.white, size: 50),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      album.albumName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildArtistList(BuildContext context) {
    if (artists.isEmpty) {
      return Center(
        child: Text(
          'No artists available',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return Container(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtistAlbumsPage(artist: artist),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          artist.artistImage,
                        ),
                        radius: 40,
                        backgroundColor: Colors.grey,
                        onBackgroundImageError: (exception, stackTrace) {},
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      artist.artistName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildSongList(BuildContext context) {
    List<Song> songs = [];
    for (var artist in artists) {
      for (var album in artist.albums) {
        songs.addAll(album.songs);
      }
    }
    if (songs.isEmpty) {
      return Center(
        child: Text(
          'No songs available',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      final displayedSongs = songs.take(10).toList();

      return Container(
        child: Column(
          children: displayedSongs.map((song) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(Icons.play_circle_fill, color: Colors.white),
                title: Text(
                  song.songName,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(
                  'by ${getArtistNameBySong(song)}',
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
                        playlist: songs,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  String getArtistNameBySong(Song song) {
    for (var artist in artists) {
      for (var album in artist.albums) {
        if (album.songs.contains(song)) {
          return artist.artistName;
        }
      }
    }
    return 'Unknown Artist';
  }
}
