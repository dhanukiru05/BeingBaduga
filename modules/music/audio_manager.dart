import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _audioPlayer = AudioPlayer();
  final _mediaItems = <MediaItem>[];

  AudioPlayerHandler() {
    _mediaItems.add(MediaItem(
      id: 'song',
      album: 'Album Name',
      title: 'Song Title',
      artist: 'Artist Name',
      duration: const Duration(minutes: 3),
      artUri: Uri.parse('https://example.com/song-image.jpg'),
    ));

    // Broadcasting the current playback state to clients.
    _audioPlayer.playbackEventStream.map(_transformEvent).pipe(playbackState);
    
    // Set the initial queue and media item.
    queue.add(_mediaItems);
    mediaItem.add(_mediaItems[0]);
    
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        mediaItem.add(_mediaItems[index]);
      }
    });
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> skipToNext() async {
    _audioPlayer.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    _audioPlayer.seekToPrevious();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.one) {
      _audioPlayer.setLoopMode(LoopMode.one);
    } else {
      _audioPlayer.setLoopMode(LoopMode.off);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _audioPlayer.setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.play,
        MediaControl.pause,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _audioPlayer.processingState.toProcessingState(),
      playing: _audioPlayer.playing,
      updatePosition: _audioPlayer.position,
      bufferedPosition: _audioPlayer.bufferedPosition,
      speed: _audioPlayer.speed,
      queueIndex: _audioPlayer.currentIndex,
    );
  }
}

extension on ProcessingState {
  AudioProcessingState toProcessingState() {
    switch (this) {
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      default:
        return AudioProcessingState.idle;
    }
  }
}
