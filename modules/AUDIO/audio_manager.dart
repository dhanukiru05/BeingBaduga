// lib/audio_manager.dart
import 'package:beingbaduga/modules/AUDIO/music.dart';
import 'package:beingbaduga/modules/AUDIO/music_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioManager {
  // Singleton instance
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() => _instance;

  AudioManager._internal() {
    _init();
  }

  late AudioPlayer _audioPlayer;
  List<Song> _playlist = [];
  int _currentIndex = 0;

  // Streams to listen to playback state and current song
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;

  AudioPlayer get audioPlayer => _audioPlayer;

  List<Song> get playlist => _playlist;

  int get currentIndex => _currentIndex;

  Song? get currentSong =>
      (_playlist.isNotEmpty && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    _playlist = songs;
    _currentIndex = initialIndex;

    try {
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: _playlist.map((song) => audioInit(song)).toList(),
        ),
        initialIndex: _currentIndex,
      );
    } catch (e) {
      print("Error setting playlist: $e");
    }
  }

  AudioSource audioInit(Song song) {
    final mediaItem = MediaItem(
      id: song.songUrl,
      album: song.albumName ?? 'Unknown Album',
      title: song.songName,
      artist: song.artistName ?? 'Unknown Artist',
      artUri: Uri.parse(song.songImage),
    );
    return AudioSource.uri(Uri.parse(song.songUrl), tag: mediaItem);
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position, {int? index}) {
    _audioPlayer.seek(position, index: index);
  }

  void toggleShuffle() {
    bool isShuffleModeEnabled = _audioPlayer.shuffleModeEnabled;
    _audioPlayer.setShuffleModeEnabled(!isShuffleModeEnabled);
    if (!isShuffleModeEnabled) {
      _audioPlayer.shuffle();
    }
  }

  void toggleRepeat() {
    LoopMode currentLoopMode = _audioPlayer.loopMode;
    LoopMode newLoopMode;
    switch (currentLoopMode) {
      case LoopMode.off:
        newLoopMode = LoopMode.one;
        break;
      case LoopMode.one:
        newLoopMode = LoopMode.all;
        break;
      case LoopMode.all:
        newLoopMode = LoopMode.off;
        break;
    }
    _audioPlayer.setLoopMode(newLoopMode);
  }

  // Dispose the AudioPlayer when needed
  void dispose() {
    _audioPlayer.dispose();
  }

  void _init() {
    _audioPlayer = AudioPlayer();

    // Listen to current index changes
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < _playlist.length) {
        _currentIndex = index;
      }
    });
  }
}
