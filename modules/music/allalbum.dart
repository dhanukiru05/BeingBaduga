import 'package:flutter/material.dart';
import 'package:beingbaduga/modules/music/music_models.dart';
import 'package:beingbaduga/modules/music/songs_page.dart';

class AllAlbumsPage extends StatelessWidget {
  final List<Artist> artists;

  AllAlbumsPage({required this.artists});

  @override
  Widget build(BuildContext context) {
    List<Album> allAlbums = artists.expand((artist) => artist.albums).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Albums'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: allAlbums.length,
        itemBuilder: (context, index) {
          Album album = allAlbums[index];
          Artist artist = artists[index];
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
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(album.albumImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0)),
                  ),
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
