// lib/bottom_player_bar.dart
import 'package:beingbaduga/modules/AUDIO/audio_manager.dart';
import 'package:beingbaduga/modules/AUDIO/music.dart';
import 'package:beingbaduga/modules/AUDIO/player.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BottomPlayerBar extends StatelessWidget {
  final AudioManager audioManager = AudioManager();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioManager.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

        final currentSong = audioManager.currentSong;

        if (currentSong == null) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerPage(
                  song: currentSong,
                  playlist: audioManager.playlist,
                ),
              ),
            );
          },
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    currentSong.songImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: Icon(Icons.music_note, color: Colors.white),
                      );
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentSong.songName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentSong.artistName ?? 'Unknown Artist',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      audioManager.pause();
                    } else {
                      audioManager.play();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
