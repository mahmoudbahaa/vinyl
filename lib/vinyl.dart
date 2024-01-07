import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:vinyl/core/background_service.dart';
import 'package:vinyl/core/mediakit_player.dart';
export 'package:audio_service/audio_service.dart' show AudioServiceConfig;
export 'package:media_kit/media_kit.dart' show Media;

class Vinyl {
  // singleton
  Vinyl._init();

  // Single instance of the class
  static final Vinyl _instance = Vinyl._init();

  // Getter to access the instance
  static Vinyl get i => _instance;

  Future<void> init({AudioServiceConfig? audioConfig}) async {
    //TODO implement init for media kit and audio service
    // androidNotificationChannelId:
    // PlayerConstants.androidNotificationChannelId,
    // androidNotificationChannelName:
    // PlayerConstants.androidNotificationChannelName,
    // androidNotificationOngoing: true,
    // add androidNotificationIcon

    // initialize mediakit
    MediaKit.ensureInitialized();
    final mKit = MediaKitPlayer(mediaKit: Player());

    final isBackgroundAudioSupported =
        Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

    if (isBackgroundAudioSupported) {
      if (audioConfig == null) {
        throw Exception('Audioconfig is required for audio service to work');
      }

      backgroundPlayer = await initBackgroundAudio(mKit, audioConfig);
    } else {
      player = mKit;
    }
  }

  late final MediaKitBackgroundPlayer? backgroundPlayer;
  late final MediaKitPlayer? player;
}
