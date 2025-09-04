// lib/MusicPlayerPage.dart
import 'dart:ui';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:beingbaduga/modules/AUDIO/audio_manager.dart';
import 'package:beingbaduga/modules/AUDIO/bottom_player_bar.dart';
import 'package:beingbaduga/modules/AUDIO/music_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerPage extends StatefulWidget {
  final Song song;
  final List<Song> playlist;

  MusicPlayerPage({required this.song, required this.playlist});

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioManager audioManager = AudioManager(); // Access AudioManager
  bool isPlaying = false;
  bool isShuffle = false;
  bool isRepeat = false;
  Duration duration = Duration();
  Duration position = Duration();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Find the index of the current song in the playlist
    currentIndex = widget.playlist.indexOf(widget.song);
    if (currentIndex == -1) currentIndex = 0;

    setupAudio();
  }

  Future<void> setupAudio() async {
    try {
      if (audioManager.playlist != widget.playlist ||
          audioManager.currentIndex != currentIndex) {
        await audioManager.setPlaylist(widget.playlist,
            initialIndex: currentIndex);
      }

      // Listen to playback state
      audioManager.playerStateStream.listen((state) {
        setState(() {
          isPlaying = state.playing;
        });
      });

      // Listen to duration changes
      audioManager.durationStream.listen((d) {
        setState(() {
          duration = d ?? Duration();
        });
      });

      // Listen to position changes
      audioManager.positionStream.listen((p) {
        setState(() {
          position = p;
        });
      });

      // Listen to current index changes
      audioManager.currentIndexStream.listen((index) {
        if (index != null && index < widget.playlist.length) {
          setState(() {
            currentIndex = index;
          });
        }
      });

      // Start playing if not already
      if (!audioManager.audioPlayer.playing &&
          audioManager.audioPlayer.processingState !=
              ProcessingState.completed) {
        audioManager.play();
      }
    } catch (e) {
      print("Error setting up audio: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Do not dispose AudioManager's AudioPlayer here, as it's used globally
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioManager.seek(newDuration);
  }

  void toggleShuffle() {
    setState(() {
      isShuffle = !isShuffle;
    });
    audioManager.toggleShuffle();
  }

  void toggleRepeat() {
    setState(() {
      isRepeat = !isRepeat;
    });
    audioManager.toggleRepeat();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  void playNextSong() {
    audioManager.audioPlayer.seekToNext();
  }

  void playPreviousSong() {
    audioManager.audioPlayer.seekToPrevious();
  }

  @override
  Widget build(BuildContext context) {
    String artistName =
        audioManager.currentSong?.artistName ?? 'Unknown Artist';
    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackgroundImage(context),
          _buildGlassyOverlay(context),
          _buildContent(context, artistName),
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
        color: Colors.black.withOpacity(0.6),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String artistName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CarouselSlider.builder(
                itemCount: audioManager.playlist.length,
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  initialPage: audioManager.currentIndex,
                  viewportFraction: 0.7,
                  onPageChanged: (index, reason) {
                    setState(() {
                      audioManager.audioPlayer
                          .seek(Duration.zero, index: index);
                      audioManager.play();
                    });
                  },
                ),
                itemBuilder: (context, index, realIdx) {
                  final song = audioManager.playlist[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        audioManager.audioPlayer
                            .seek(Duration.zero, index: index);
                        audioManager.play();
                      });
                    },
                    child: ClipOval(
                      child: Image.network(
                        song.songImage,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey,
                            child: Icon(Icons.music_note,
                                color: Colors.white, size: 100),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                audioManager.currentSong?.songName ?? 'Unknown Song',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 10),
              Text(
                artistName,
                style: TextStyle(color: Colors.white70, fontSize: 18),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 30),
              StreamBuilder<Duration?>(
                stream: audioManager.durationStream,
                builder: (context, snapshot) {
                  Duration dur = snapshot.data ?? Duration();
                  return StreamBuilder<Duration>(
                    stream: audioManager.positionStream,
                    builder: (context, snapshot) {
                      Duration pos = snapshot.data ?? Duration();
                      return Slider(
                        activeColor: Colors.white,
                        inactiveColor: Colors.white24,
                        value: pos.inSeconds
                            .toDouble()
                            .clamp(0.0, dur.inSeconds.toDouble()),
                        min: 0.0,
                        max: dur.inSeconds.toDouble(),
                        onChanged: (double value) {
                          seekToSecond(value.toInt());
                        },
                      );
                    },
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      formatTime(duration),
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      isShuffle ? Icons.shuffle_on : Icons.shuffle,
                      color: Colors.white,
                    ),
                    onPressed: toggleShuffle,
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.skip_previous,
                        color: Colors.white, size: 30),
                    onPressed: playPreviousSong,
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: Colors.white,
                        size: 50),
                    onPressed: () {
                      if (isPlaying) {
                        audioManager.pause();
                      } else {
                        audioManager.play();
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.skip_next, color: Colors.white, size: 30),
                    onPressed: playNextSong,
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(isRepeat ? Icons.repeat_on : Icons.repeat,
                        color: Colors.white, size: 30),
                    onPressed: toggleRepeat,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
