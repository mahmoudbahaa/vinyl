import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:media_kit/media_kit.dart';
import 'package:vinyl/core/background/background_service.dart';
import 'package:vinyl/core/background/mobile_player_controller.dart';
import 'package:vinyl/core/non_background/desktop_player_controller.dart';
import 'package:vinyl/core/services/mediakit_player.dart';
import 'package:vinyl/core/services/player_interface.dart';

export 'package:audio_service/audio_service.dart' show AudioServiceConfig;
export 'package:vinyl/core/services/media_record.dart' show MediaRecord;
export 'package:vinyl/core/services/player_interface.dart';

final vinyl = Vinyl.i;

class Vinyl {
  // singleton
  Vinyl._init();

  // Single instance of the class
  static final Vinyl _instance = Vinyl._init();

  // Getter to access the instance
  static Vinyl get i => _instance;

  Future<void> init({AudioServiceConfig? audioConfig}) async {
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
        player = MobilePlayerController(audioHandler: tmp);
      } on Exception catch (e) {
        debugPrint('Failed to initialize background player');
        debugPrint(e.toString());
      }
    } else {
      player = DesktopPlayerController(player: mKit);
    }
  }

  void dispose() => player.dispose();

  late final PlayerInterface player;
}
