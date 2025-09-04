
class Artist {
  final int artistId;
  final String artistName;
  final String artistImage;
  final List<Album> albums;

  Artist({
    required this.artistId,
    required this.artistName,
    required this.artistImage,
    required this.albums,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    var albumList = <Album>[];
    if (json['albums'] != null) {
      for (var albumJson in json['albums']) {
        albumList.add(Album.fromJson(albumJson, json['artist_name']));
      }
    }
    return Artist(
      artistId: json['artist_id'],
      artistName: json['artist_name'],
      artistImage: json['artist_image'],
      albums: albumList,
    );
  }
}

class Album {
  final int albumId;
  final String albumName;
  final String albumImage;
  final List<Song> songs;

  Album({
    required this.albumId,
    required this.albumName,
    required this.albumImage,
    required this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json, String artistName) {
    var songList = <Song>[];
    if (json['songs'] != null) {
      for (var songJson in json['songs']) {
        Song song = Song.fromJson(songJson);
        song.artistName = artistName;
        songList.add(song);
      }
    }
    return Album(
      albumId: json['album_id'],
      albumName: json['album_name'],
      albumImage: json['album_image'],
      songs: songList,
    );
  }
}

class Song {
  final int songId;
  final String songName;
  final String songImage;
  final String songUrl;
  String? artistName;
  String? albumName;

  Song({
    required this.songId,
    required this.songName,
    required this.songImage,
    required this.songUrl,
    this.artistName,
    this.albumName,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songId: json['song_id'],
      songName: json['song_name'],
      songImage: json['song_image'],
      songUrl: json['song_url'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          songId == other.songId;

  @override
  int get hashCode => songId.hashCode;
}
