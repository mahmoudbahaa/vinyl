import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:media_kit/media_kit.dart';
import 'package:vinyl/background/background_service.dart';
import 'package:vinyl/non_background/desktop_player_service.dart';
import 'package:vinyl/services/mediakit_player.dart';
import 'package:vinyl/services/player_interface.dart';

export 'package:audio_service/audio_service.dart' show AudioServiceConfig;
export 'package:audio_service/audio_service.dart' show MediaItem;
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

      try {
        final tmp = await initBackgroundAudio(mKit, audioConfig);
      } on Exception catch (e) {
        debugPrint('Failed to initialize background player');
        debugPrint(e.toString());
      }
    } else {
      player = DesktopPlayerController(player: mKit);
    }
  }

  //TODO add dispose

  late final PlayerInterface player;
}
