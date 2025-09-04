import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    // Initialize the player and load a media item
    _audioPlayer.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
      ));
    });

    // Listen to errors
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        stop();
      }
    }, onError: (Object e, StackTrace stackTrace) {
      // Handle error
      print('Error: $e');
    });
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() => _audioPlayer.stop();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  // Additional functionality for shuffle and repeat
  Future<void> setShuffleModeEnabled(bool isEnabled) async {
    await _audioPlayer.setShuffleModeEnabled(isEnabled);
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = repeatMode == AudioServiceRepeatMode.one
        ? LoopMode.one
        : LoopMode.off;
    await _audioPlayer.setLoopMode(loopMode);
  }
}

// Extension on AudioHandler to set shuffle mode easily
extension ShuffleModeExtension on AudioHandler {
  void setShuffleModeEnabled(bool isShuffle) {
    if (this is AudioPlayerHandler) {
      (this as AudioPlayerHandler).setShuffleModeEnabled(isShuffle);
    }
  }

  void setRepeatMode(AudioServiceRepeatMode repeatMode) {
    if (this is AudioPlayerHandler) {
      (this as AudioPlayerHandler).setRepeatMode(repeatMode);
    }
  }
}
