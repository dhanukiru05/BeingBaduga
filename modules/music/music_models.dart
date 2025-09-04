// To parse this JSON data, do
//
//     final artist = artistFromJson(jsonString);

import 'dart:convert';

List<Artist> artistFromJson(String str) => List<Artist>.from(json.decode(str).map((x) => Artist.fromJson(x)));

String artistToJson(List<Artist> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Artist {
  int artistId;
  String artistName;
  String artistImage;
  List<Album> albums;

  Artist({
    required this.artistId,
    required this.artistName,
    required this.artistImage,
    required this.albums,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
    artistId: json["artist_id"],
    artistName: json["artist_name"],
    artistImage: json["artist_image"],
    albums: List<Album>.from(json["albums"].map((x) => Album.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "artist_id": artistId,
    "artist_name": artistName,
    "artist_image": artistImage,
    "albums": List<dynamic>.from(albums.map((x) => x.toJson())),
  };
}

class Album {
  int albumId;
  String albumName;
  String albumImage;
  List<Song> songs;

  Album({
    required this.albumId,
    required this.albumName,
    required this.albumImage,
    required this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    albumId: json["album_id"],
    albumName: json["album_name"],
    albumImage: json["album_image"],
    songs: List<Song>.from(json["songs"].map((x) => Song.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "album_id": albumId,
    "album_name": albumName,
    "album_image": albumImage,
    "songs": List<dynamic>.from(songs.map((x) => x.toJson())),
  };
}

class Song {
  int songId;
  String songName;
  String songImage;
  String songUrl;

  Song({
    required this.songId,
    required this.songName,
    required this.songImage,
    required this.songUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    songId: json["song_id"],
    songName: json["song_name"],
    songImage: json["song_image"],
    songUrl: json["song_url"],
  );

  Map<String, dynamic> toJson() => {
    "song_id": songId,
    "song_name": songName,
    "song_image": songImage,
    "song_url": songUrl,
  };
}
