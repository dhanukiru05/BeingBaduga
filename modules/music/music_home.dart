import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart'; // For optimized image loading
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beingbaduga/modules/music/MusicPlayerPage.dart';
import 'package:beingbaduga/modules/music/allalbum.dart';
import 'package:beingbaduga/modules/music/allartist.dart';
import 'package:beingbaduga/modules/music/allsong.dart';
import 'package:beingbaduga/modules/music/music_models.dart';
import 'package:beingbaduga/modules/music/songs_page.dart';

class MusicHomePage extends StatefulWidget {
  @override
  _MusicHomePageState createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  late Future<List<Artist>> _artistsFuture;

  @override
  void initState() {
    super.initState();
    _artistsFuture = fetchArtists();
  }

  Future<List<Artist>> fetchArtists() async {
    try {
      final response = await http
          .get(Uri.parse('https://beingbaduga.com/being_baduga/album.php'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          return jsonResponse
              .map((artistJson) => Artist.fromJson(artistJson))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load artists');
      }
    } catch (e) {
      throw Exception('Error fetching artists: $e');
    }
  }

  Future<void> _refreshArtists() async {
    setState(() {
      _artistsFuture = fetchArtists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Artist>>(
        future: _artistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            List<Artist> artists = snapshot.data!;
            List<Song> allSongs = artists
                .expand((artist) => artist.albums)
                .expand((album) => album.songs)
                .toList();
            List<Song> limitedSongs = allSongs.take(5).toList();

            return RefreshIndicator(
              onRefresh: _refreshArtists,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarouselSlider(),
                    SizedBox(height: 16),
                    _buildArtistsSection(artists),
                    SizedBox(height: 20),
                    _buildAlbumsSection(artists),
                    SizedBox(height: 20),
                    _buildSongsSection(limitedSongs, allSongs, artists[0]),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // AppBar with a refresh button
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Music Home'),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _refreshArtists,
        ),
      ],
    );
  }

  // Loading Indicator Widget
  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  // Error State Widget
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshArtists,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No data available',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  // Carousel Slider Widget
  Widget _buildCarouselSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 250,
          viewportFraction: 0.8,
          autoPlay: true,
          enlargeCenterPage: true,
          autoPlayInterval: Duration(seconds: 3),
        ),
        items: List.generate(5, (index) {
          return _buildCarouselItem(index);
        }),
      ),
    );
  }

  // Individual Carousel Item with modern design
  Widget _buildCarouselItem(int index) {
    return GestureDetector(
      onTap: () {
        // Handle carousel item tap if needed
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://picsum.photos/500/300?random=${index + 1}',
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Center(child: Icon(Icons.error)),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  'Featured ${index + 1}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Artists Section with enhanced UI
  Widget _buildArtistsSection(List<Artist> artists) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SectionWidget(
        title: 'Artists',
        onViewMore: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllArtistsPage(artists: artists),
            ),
          );
        },
        child: SizedBox(
          height: 150, // Adjusted height for consistency
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              return _buildArtistCard(artists[index]);
            },
          ),
        ),
      ),
    );
  }

  // Albums Section with advanced UI
  Widget _buildAlbumsSection(List<Artist> artists) {
    List<Album> albums = artists.expand((artist) => artist.albums).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SectionWidget(
        title: 'Albums',
        onViewMore: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllAlbumsPage(artists: artists),
            ),
          );
        },
        child: SizedBox(
          height: 220, // Adjusted height for album cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              return _buildAlbumCard(albums[index], artists[0]);
            },
          ),
        ),
      ),
    );
  }

  // Songs Section with enhanced UI
  Widget _buildSongsSection(
      List<Song> limitedSongs, List<Song> allSongs, Artist artist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SectionWidget(
        title: 'Songs',
        onViewMore: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllSongsPage(
                songs: allSongs,
                artist: artist,
              ),
            ),
          );
        },
        child: Column(
          children: [
            _buildSongList(limitedSongs, artist),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable Section Widget with title and "View More" button
  Widget SectionWidget({
    required String title,
    required VoidCallback onViewMore,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with modern design
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onViewMore,
              child: Text('View More'),
            ),
          ],
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  // Artist Card with enhanced design and shadows
  Widget _buildArtistCard(Artist artist) {
    return GestureDetector(
      onTap: () {
        // Navigate to artist details or relevant page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllArtistsPage(artists: [artist]),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Artist Image with circular design
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: artist.artistImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Center(child: Icon(Icons.error)),
              ),
            ),
            SizedBox(height: 8),
            // Artist Name
            Text(
              artist.artistName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Song List Widget with advanced Container design
  Widget _buildSongList(List<Song> songs, Artist artist) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        Song song = songs[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerPage(
                  songs: songs,
                  artist: artist,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Song Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: song.songImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Song Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.songName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        artist.artistName ?? 'Unknown Artist',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Play Button
                IconButton(
                  icon: Icon(Icons.play_arrow,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerPage(
                          songs: songs,
                          artist: artist,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Album Card with modern design
  Widget _buildAlbumCard(Album album, Artist artist) {
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
        width: 160,
        margin: EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover Image with modern design
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: album.albumImage,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 160,
                  height: 160,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 160,
                  height: 160,
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            SizedBox(height: 8),
            // Album Name
            Text(
              album.albumName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            // Optional: Artist Name or other details
            SizedBox(height: 4),
            Text(
              artist.artistName == null ? 'Unknown Artist' : artist.artistName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
