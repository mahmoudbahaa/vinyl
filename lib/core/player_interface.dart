import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:media_kit/media_kit.dart';

const eMessage =
    'You forgot to initialize Vinyl\nCall "Vinyl.init()" in main.dart';

enum ButtonState {
  paused,
  playing,
  loading,
}

class ProgressBarState {
  const ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;

  ProgressBarState copyWith({
    Duration? current,
    Duration? buffered,
    Duration? total,
  }) {
    return ProgressBarState(
      current: current ?? this.current,
      buffered: buffered ?? this.buffered,
      total: total ?? this.total,
    );
  }
}

/// Store media information here
class MediaRecord extends MediaItem {
  MediaRecord({
    required super.id,
    required super.title,
    required this.mediaUri,
    this.mediaHeaders = const {},
    super.album,
    super.artHeaders,
    super.artist,
    super.artUri,
    super.displayDescription,
    super.displaySubtitle,
    super.displayTitle,
    super.duration,
    super.extras,
    super.genre,
    super.playable,
    super.rating,
  });

  /// store media url can be file or web
  final String mediaUri;

  /// headers for the media file
  final Map<String, String> mediaHeaders;

  /// convert media record to media
  Media convertToMedia() {
    return Media(
      mediaUri,
      httpHeaders: mediaHeaders,
      extras: toMap(),
    );
  }

  Map<String,String> toMap(){

  }

  factory MediaRecord fromMap(Map<String,String> data){

  }

}

/// Define default metadata to display
/// e.g. default image or title
class DefaultMetadata {
  DefaultMetadata({required this.defaultImage, required this.defaultTitle});

  final String defaultImage;
  final String defaultTitle;
}

abstract class PlayerInterface {
  PlayerInterface({required this.metadata});

  final DefaultMetadata metadata;

  final isStopped = ValueNotifier(true);
  final currentSongTitle = ValueNotifier('');
  final currentImage = ValueNotifier('');
  final playbackSpeed = ValueNotifier<double>(1);

// final currentIndex = ValueNotifier('');
  final progressState = ValueNotifier(
    const ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  final isFirstSong = ValueNotifier(true);
  final isLastSong = ValueNotifier(true);
  final playButton = ValueNotifier(ButtonState.paused);

// final isShuffleModeEnabled = ValueNotifier(false);

  ///Use this to load your data in
  Future<void> loadMedia(
    List<MediaItem> input, {
    Duration listenedPos = Duration.zero,
    int trackIndex = 0,
  });

  Future<void> play();

  Future<void> pause();

  Future<void> next();

  Future<void> previous();

  Future<void> setSpeed();

  Future<void> seek(Duration position);

  Future<void> skipToTrack({
    Duration position = Duration.zero,
    int trackIndex = 0,
  });

  Future<void> seekForward(Duration positionOffset);

  Future<void> seekBackward(Duration positionOffset);

  Future<void> stop();
}
