// albums_page.dart

import 'package:beingbaduga/modules/music/music_models.dart';
import 'package:beingbaduga/modules/music/songs_page.dart';
import 'package:flutter/material.dart';

class AlbumsPage extends StatelessWidget {
  final Artist artist;

  AlbumsPage({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${artist.artistName} Albums'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: artist.albums.length,
        itemBuilder: (context, index) {
          final album = artist.albums.toList()[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongsPage(
                    album: album,
                    artist: artist,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(album.albumImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Text(
                    album.albumName,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
