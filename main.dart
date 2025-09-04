import 'package:beingbaduga/modules/AUDIO/music.dart';
import 'package:beingbaduga/modules/rtuals/rituals.dart';
import 'package:flutter/material.dart';
import 'package:beingbaduga/login.dart';
import 'package:beingbaduga/modules/about/about.dart';
import 'package:beingbaduga/modules/book/book.dart';
import 'package:beingbaduga/modules/events/events.dart';
import 'package:beingbaduga/modules/locations/maps.dart';
import 'package:beingbaduga/package.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:secure_application/secure_application.dart';
import 'firebase/PushNotificationService.dart';
import 'splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(MyApp());

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  await FirebaseMessaging.instance.subscribeToTopic("news");

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

Future<void> backgroundHandler(RemoteMessage message) async {
  print(
      'Handling a background message ${message.notification!.android!.imageUrl}');
}

class MyApp extends StatelessWidget {
  get categoryId => null;
  final PushNotificationService _notificationService =
      PushNotificationService();

  get user => null;

  get packageId => null;

  @override
  Widget build(BuildContext context) {
    _notificationService.initialize();

    return SecureApplication(
      child: MaterialApp(
        title: 'Multi Module App',
        theme: ThemeData(
          primaryColor: Color(0xFFBE1744),
          hintColor: Color(0xFFEC407A),
          scaffoldBackgroundColor: Color(0xFFFCE4EC),
          appBarTheme: AppBarTheme(
            color: Color(0xFFBE1744),
            titleTextStyle: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(
              color: Color(0xFFFFFFFF),
            ),
          ),
          cardColor: Color(0xFFFCE4EC),
          textTheme: TextTheme(
            titleLarge: TextStyle(
              color: Color(0xFFEC407A),
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF4A4A4A),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/home': (context) => HomePage(members: []),
          '/login': (context) => LoginPage(),
          '/about': (context) => AboutUsPage(),
          '/music': (context) => MusicPage(
                user: user,
              ),
          '/festivals': (context) => EventsPage(),
          '/ebooks': (context) => EBookPage(
                user: user,
                packageId: packageId,
              ),
          '/locations': (context) => MapsPage(),
          '/rituals': (context) => RitualsPage(),
          '/business': (context) =>
              PackagesPage(moduleName: 'Business', categoryId: categoryId),
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List members;

  const HomePage({Key? key, required this.members}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Replace this with your actual music player logic
  int currentTrackIndex = 0;
  final List<String> tracks = [
    'Track 1',
    'Track 2',
    'Track 3'
  ]; // Example track names

  void playTrack(int index) {
    // Add your logic to play the selected track
    print('Playing: ${tracks[index]}');
    setState(() {
      currentTrackIndex = index;
    });
  }

  void nextTrack() {
    if (currentTrackIndex < tracks.length - 1) {
      playTrack(currentTrackIndex + 1);
    }
  }

  void previousTrack() {
    if (currentTrackIndex > 0) {
      playTrack(currentTrackIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.skip_previous),
            onPressed: previousTrack,
          ),
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: nextTrack,
          ),
        ],
      ),
      body: Center(
        child: Text('Now playing: ${tracks[currentTrackIndex]}'),
      ),
    );
  }
}
