// lib/modules/music/MusicPlayerPage.dart

import 'package:beingbaduga/modules/music/music_models.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MusicPlayerPage extends StatefulWidget {
  final List<Song> songs;
  final Artist artist;
  final int initialIndex;

  const MusicPlayerPage({
    Key? key,
    required this.songs,
    required this.artist,
    required this.initialIndex,
  }) : super(key: key);

  @override
  MusicPlayerPageState createState() => MusicPlayerPageState();
}

class MusicPlayerPageState extends State<MusicPlayerPage>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  late int _currentSongIndex;
  bool _isShuffle = false;
  bool _isRepeat = false;
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentSongIndex = widget.initialIndex;
    _audioPlayer = AudioPlayer();
    _initializePlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _draggableController.animateTo(
        0.8, // Expanded size
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _initializePlayer() async {
    // Configure the audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Create a list of AudioSources from your songs
    List<AudioSource> audioSources = widget.songs.map((song) {
      return AudioSource.uri(
        Uri.parse(song.songUrl),
        tag: MediaItem(
          id: '${song.songId}',
          album: widget.artist.albums.isNotEmpty
              ? widget.artist.albums[0].albumName
              : 'Unknown Album',
          title: song.songName,
          artUri: widget.artist.albums.isNotEmpty
              ? Uri.parse(widget.artist.albums[0].albumImage)
              : Uri.parse('https://via.placeholder.com/150'),
        ),
      );
    }).toList();

    // Create a ConcatenatingAudioSource playlist
    final playlist = ConcatenatingAudioSource(children: audioSources);

    try {
      // Set the playlist as the audio source
      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: _currentSongIndex,
      );
      await _audioPlayer.play();
    } catch (e) {
      print("Error loading audio source: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading song: ${e.toString()}')),
      );
    }

    // Setup listeners
    _audioPlayer.playingStream.listen((isPlaying) {
      setState(() {
        // Update UI if needed based on isPlaying
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        // Update UI if needed based on position
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        // Update UI if needed based on duration
      });
    });

    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        setState(() {
          _currentSongIndex = sequenceState.currentIndex ?? _currentSongIndex;
        });
      }
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _playNextSong();
      }
    });
  }

  void _playPauseSong() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _playNextSong() async {
    if (_isShuffle || _audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    } else if (_isRepeat) {
      await _audioPlayer.seek(Duration.zero, index: 0);
    } else {
      await _audioPlayer.pause();
    }
  }

  void _playPreviousSong() async {
    if (_audioPlayer.position > const Duration(seconds: 3)) {
      await _audioPlayer.seek(Duration.zero);
    } else if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    } else {
      await _audioPlayer.seek(Duration.zero);
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
    _audioPlayer.setShuffleModeEnabled(_isShuffle);
    if (_isShuffle) {
      _audioPlayer.shuffle();
    }
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeat = !_isRepeat;
    });
    _audioPlayer.setLoopMode(_isRepeat ? LoopMode.all : LoopMode.off);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draggableController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    Song currentSong = widget.songs[_currentSongIndex];
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentSong.songName,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: _audioPlayer.playing
          ? FloatingActionButton(
              onPressed: () {
                // Optionally, implement a mini-player or other functionality
                // For now, we'll pause/play the song
                _playPauseSong();
              },
              child: Icon(
                _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            // Base Layer: Song List Container
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: widget.songs.length,
                  itemBuilder: (context, index) {
                    Song song = widget.songs[index];
                    bool isCurrent = index == _currentSongIndex;
                    return ListTile(
                      leading: Icon(
                        isCurrent ? Icons.play_arrow : Icons.music_note,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        song.songName,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        widget.artist.artistName.isNotEmpty
                            ? widget.artist.artistName
                            : 'Unknown Artist',
                        style: TextStyle(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      onTap: () {
                        _audioPlayer.seek(Duration.zero, index: index);
                        setState(() {
                          _currentSongIndex = index;
                        });
                      },
                      tileColor: isCurrent
                          ? Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Overlay Layer: DraggableScrollableSheet for Player
            DraggableScrollableSheet(
              controller: _draggableController,
              initialChildSize: 0.8, // Start expanded
              minChildSize: 0.1,
              maxChildSize: 0.8,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // Handle Bar
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Player Content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: [
                              // Minimized Player
                              Row(
                                children: [
                                  // Album Art
                                  Container(
                                    width: screenWidth * 0.15,
                                    height: screenWidth * 0.15,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(currentSong.songImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Song Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentSong.songName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          widget.artist.artistName.isNotEmpty
                                              ? widget.artist.artistName
                                              : 'Unknown Artist',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Play/Pause Button
                                  IconButton(
                                    icon: Icon(
                                      _audioPlayer.playing
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    onPressed: _playPauseSong,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Expanded Player Content
                              Column(
                                children: [
                                  // Large Album Art
                                  Container(
                                    width: screenWidth * 0.6,
                                    height: screenWidth * 0.6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(currentSong.songImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Song Title
                                  Text(
                                    currentSong.songName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  // Artist Name
                                  Text(
                                    widget.artist.artistName.isNotEmpty
                                        ? widget.artist.artistName
                                        : 'Unknown Artist',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 20),
                                  // Song Progress
                                  StreamBuilder<Duration>(
                                    stream: _audioPlayer.positionStream,
                                    builder: (context, snapshot) {
                                      final position =
                                          snapshot.data ?? Duration.zero;
                                      final duration = _audioPlayer.duration ??
                                          Duration.zero;
                                      return Column(
                                        children: [
                                          Slider(
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            inactiveColor: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.3),
                                            value: position.inSeconds
                                                .clamp(0, duration.inSeconds)
                                                .toDouble(),
                                            max: duration.inSeconds.toDouble() >
                                                    0
                                                ? duration.inSeconds.toDouble()
                                                : 1.0,
                                            onChanged: (value) async {
                                              await _audioPlayer.seek(
                                                Duration(
                                                    seconds: value.toInt()),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _formatDuration(position),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.grey,
                                                      ),
                                                ),
                                                Text(
                                                  _formatDuration(duration),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors.grey,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  // Playback Controls
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Shuffle
                                      IconButton(
                                        icon: Icon(
                                          _isShuffle
                                              ? Icons.shuffle_on
                                              : Icons.shuffle,
                                          color: _isShuffle
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                        ),
                                        onPressed: _toggleShuffle,
                                      ),
                                      const SizedBox(width: 10),
                                      // Previous
                                      IconButton(
                                        icon: Icon(
                                          Icons.skip_previous,
                                          size: 30,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                        onPressed: _playPreviousSong,
                                      ),
                                      const SizedBox(width: 20),
                                      // Play/Pause
                                      GestureDetector(
                                        onTap: _playPauseSong,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Icon(
                                            _audioPlayer.playing
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // Next
                                      IconButton(
                                        icon: Icon(
                                          Icons.skip_next,
                                          size: 30,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                        onPressed: _playNextSong,
                                      ),
                                      const SizedBox(width: 10),
                                      // Repeat
                                      IconButton(
                                        icon: Icon(
                                          _isRepeat
                                              ? Icons.repeat_on
                                              : Icons.repeat,
                                          color: _isRepeat
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                        ),
                                        onPressed: _toggleRepeat,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
