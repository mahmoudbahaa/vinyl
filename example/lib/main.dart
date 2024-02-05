import 'package:flutter/material.dart';
import 'package:vinyl/services/media_record.dart';
import 'package:vinyl/vinyl.dart';

final vinyl = Vinyl.i;

void main() {
  const config = AudioServiceConfig(
      androidNotificationChannelId: "app.dumb.vinyltest",
      androidNotificationChannelName: "test Player",
      androidNotificationOngoing: true);
  vinyl.init(audioConfig: config);

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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

  List<MediaObject> medias = [
    MediaObject('test1', 'todo',
        'https://www2.cs.uic.edu/~i101/SoundFiles/BabyElephantWalk60.wav'),
    MediaObject('test2', 'todo',
        'https://www2.cs.uic.edu/~i101/SoundFiles/CantinaBand60.wav'),
    MediaObject('test3', 'todo',
        'https://www2.cs.uic.edu/~i101/SoundFiles/gettysburg.wav'),
    MediaObject('test4', 'todo',
        'https://www2.cs.uic.edu/~i101/SoundFiles/PinkPanther60.wav'),
    MediaObject('test5', 'todo',
        'https://www2.cs.uic.edu/~i101/SoundFiles/StarWars60.wav'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                final item = MediaRecord(
                  id: '123123',
                  title: medias.first.name,
                  mediaUri: medias.first.uri,
                );
                await vinyl.player.loadMedia([item]);
                await vinyl.player.play();
              },
              child: const Text('Play me'))
        ],
      ),
    );
  }
}

class MediaObject {
  final String name;
  final String image;
  final String uri;

  MediaObject(this.name, this.image, this.uri);
}
