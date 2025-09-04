// lib/ArtistAlbumsPage.dart
import 'dart:ui';
import 'package:beingbaduga/modules/AUDIO/AlbumSongsPage.dart';
import 'package:beingbaduga/modules/AUDIO/audio_manager.dart';
import 'package:beingbaduga/modules/AUDIO/bottom_player_bar.dart';
import 'package:beingbaduga/modules/AUDIO/music_model.dart';
import 'package:flutter/material.dart';

class ArtistAlbumsPage extends StatefulWidget {
  final Artist artist;

  ArtistAlbumsPage({required this.artist});

  @override
  _ArtistAlbumsPageState createState() => _ArtistAlbumsPageState();
}

class _ArtistAlbumsPageState extends State<ArtistAlbumsPage> {
  TextEditingController _searchController = TextEditingController();
  List<Album> filteredAlbums = [];
  final AudioManager audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAlbums);
    filteredAlbums = widget.artist.albums;
  }

  void _filterAlbums() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredAlbums = widget.artist.albums
          .where((album) => album.albumName.toLowerCase().contains(query))
          .toList();
    });
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
          hintText: 'Search Albums',
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

  @override
  Widget build(BuildContext context) {
    List<Song> artistSongs = [];
    for (var album in widget.artist.albums) {
      artistSongs.addAll(album.songs);
    }

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
          Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: filteredAlbums.isEmpty
                    ? Center(
                        child: Text(
                          'No albums available for this artist',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredAlbums.length,
                        itemBuilder: (context, index) {
                          final album = filteredAlbums[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Image.network(
                                album.albumImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.album, color: Colors.white),
                              ),
                              title: Text(
                                album.albumName,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AlbumSongsPage(album: album),
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
}
