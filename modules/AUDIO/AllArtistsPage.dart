// lib/AllArtistsPage.dart
import 'dart:ui';
import 'package:beingbaduga/modules/AUDIO/ArtistAlbumsPage.dart';
import 'package:beingbaduga/modules/AUDIO/bottom_player_bar.dart';
import 'package:beingbaduga/modules/AUDIO/music_model.dart';
import 'package:flutter/material.dart';

class AllArtistsPage extends StatefulWidget {
  final List<Artist> artists;

  AllArtistsPage({required this.artists});

  @override
  _AllArtistsPageState createState() => _AllArtistsPageState();
}

class _AllArtistsPageState extends State<AllArtistsPage> {
  TextEditingController _searchController = TextEditingController();
  List<Artist> filteredArtists = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterArtists);
    filteredArtists = widget.artists;
  }

  void _filterArtists() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredArtists = widget.artists
          .where((artist) => artist.artistName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Artists'),
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
                child: filteredArtists.isEmpty
                    ? Center(
                        child: Text(
                          'No artists available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredArtists.length,
                        itemBuilder: (context, index) {
                          final artist = filteredArtists[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(artist.artistImage),
                                backgroundColor: Colors.grey,
                                onBackgroundImageError:
                                    (exception, stackTrace) {},
                              ),
                              title: Text(
                                artist.artistName,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ArtistAlbumsPage(artist: artist),
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
          hintText: 'Search Artists',
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
  get artistName => null;
}
