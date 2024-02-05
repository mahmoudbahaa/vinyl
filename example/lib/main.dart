import 'package:flutter/material.dart';
import 'package:vinyl/services/media_record.dart';
import 'package:vinyl/vinyl.dart';

final vinyl = Vinyl.i;

Future<void> main() async {
  const config = AudioServiceConfig(
    androidNotificationChannelId: "app.dumb.vinyltest",
    androidNotificationChannelName: "test Player",
    androidNotificationOngoing: true,
  );
  await vinyl.init(audioConfig: config);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO objectives
  // testing load media
  // testing basic media controls
  // testing ui response

  List<MediaRecord> medias = [
    MediaRecord(
      id: "12312",
      title: 'mp3 test file',
      mediaUri:
          'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    ),
    MediaRecord(
      id: 'test2',
      title: 'flac test file',
      mediaUri: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Sample-FLAC-File.flac',
    ),
    MediaRecord(
      id: 'test3',
      title: 'ogg test file',
      mediaUri: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Sample-OGG-File.ogg',
    ),
    MediaRecord(
      id: 'test4',
      title: 'todoasdasdasd',
      mediaUri: 'https://www2.cs.uic.edu/~i101/SoundFiles/PinkPanther60.wav',
    ),
    MediaRecord(
      id: 'test5',
      title: 'asadsadtodo',
      mediaUri: 'https://www2.cs.uic.edu/~i101/SoundFiles/StarWars60.wav',
    ),
  ];

  Future<void> playMany() async {
    await vinyl.player.loadMedia(medias);
    await vinyl.player.play();
  }

  Future<void> playOne() async {
    await vinyl.player.loadMedia([medias.first]);
    await vinyl.player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await playOne();
            },
            child: const Text('Play one'),
          ),
          ElevatedButton(
            onPressed: () async {
              await playMany();
            },
            child: const Text('Play Many'),
          )
        ],
      ),
    );
  }
}
