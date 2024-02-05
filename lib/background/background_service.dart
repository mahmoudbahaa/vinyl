import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:vinyl/services/media_record.dart';
import 'package:vinyl/services/mediakit_player.dart';

Future<MediaKitBackgroundPlayer> initBackgroundAudio(
  MediaKitPlayer mediaKit,
  AudioServiceConfig? audioConfig,
) async {
  // initialize without background audio
  if (audioConfig == null) return MediaKitBackgroundPlayer(mediaKit: mediaKit);

  // initialize with background audio
  return AudioService.init(
    builder: () => MediaKitBackgroundPlayer(mediaKit: mediaKit),
    config: audioConfig,
  );
}

//
class MediaKitBackgroundPlayer extends BaseAudioHandler {
  MediaKitBackgroundPlayer({required this.mediaKit}) {
    try {
      initListeners();
    } catch (e) {
      debugPrint('Error initializing audio handler: $e');
    }
  }

  final MediaKitPlayer mediaKit;

  void initListeners() {
    _listenIsPlaying();
    _listenIsBuffering();
    _listenIsCompleted();
    _listenToPosition();
    _listenToBufferedPosition();
    // _listenForDurationChanges();
    _listenToMedia();
    _listenToPlaybackSpeed();
  }

  void initBackgroundPlayer() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.pause,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////////
  // playback state
  void _listenIsPlaying() {
    mediaKit.stream.playing.listen((bool playing) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          playing: playing,
        ),
      );
    });
  }

  void _listenIsBuffering() {
    mediaKit.stream.buffering.listen((bool buffering) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: buffering
              ? AudioProcessingState.buffering
              : AudioProcessingState.ready,
        ),
      );
    });
  }

  void _listenIsCompleted() {
    mediaKit.stream.completed.listen((bool completed) {
      final playerState = mediaKit.mediaKit.state;

      final currentIndex = playerState.playlist.index;
      final playlistLastIndex = playerState.playlist.medias.length - 1;
      final playListComplete = currentIndex == playlistLastIndex;

      playbackState.add(
        playbackState.value.copyWith(
          processingState: playListComplete
              ? AudioProcessingState.idle
              : AudioProcessingState.completed,
        ),
      );
    });
  }

////////////////////////////////////////////////////////////////////////////////

  // playback positions

  // current pos
  void _listenToPosition() {
    mediaKit.stream.position.listen((pos) {
      playbackState.add(
        playbackState.value.copyWith(updatePosition: pos),
      );
    });
  }

  // buffered pos
  void _listenToBufferedPosition() {
    mediaKit.stream.buffer.listen((bufferedPosition) {
      playbackState.add(
        playbackState.value.copyWith(bufferedPosition: bufferedPosition),
      );
    });
  }

  // total duration pos
  // void _listenForDurationChanges() {
  //   mediaKit.stream.duration.listen((duration) {
  //     // TODO review
  //
  //     playbackState.add(playbackState.value.copyWith(
  //       updatePosition:
  //     ))
  //
  //     final index = mediaKit.state.playlist.index;
  //     final newQueue = queue.value;
  //     if (newQueue.isEmpty) return;
  //     final oldMediaItem = newQueue[index];
  //     final newMediaItem = oldMediaItem.copyWith(duration: duration);
  //     newQueue[index] = newMediaItem;
  //
  //     queue.value = newQueue;
  //     mediaItem.add(newMediaItem);
  //   });
  // }

////////////////////////////////////////////////////////////////////////////////

  // media changes
  void _listenToMedia() {
    mediaKit.stream.playlist.listen((playlist) {
      // update queue
      queue.value = playlist.medias
          .map(
            (e) => MediaRecord.fromMediaKit(e).toMediaItem(),
          )
          .toList();

      // update current media index
      final playingIndex = playlist.index;

      playbackState.add(
        playbackState.value.copyWith(queueIndex: playingIndex),
      );

      final currentQueue = queue.value;

      // update current playing item
      mediaItem.add(currentQueue[playingIndex]);
    });
  }

  // speed state
  void _listenToPlaybackSpeed() {
    mediaKit.stream.rate.listen((speed) {
      playbackState.add(
        playbackState.value.copyWith(speed: speed),
      );
    });
  }

////////////////////////////////////////////////////////////////////////////////
  // queue controls
  void clearQueue() {
    while (queue.value.isNotEmpty) {
      queue.value.removeLast();
    }
  }

  Future<void> addMediaItem(List<MediaRecord> mediaItems) async {
    mediaKit.state.playlist.medias.addAll(
      mediaItems.map((e) => e.toMediaKit()).toList(),
    );
  }

  Future<void> loadMedia(List<MediaRecord> mediaItems) async {
    final mList = mediaItems.map((e) => e.toMediaKit()).toList();
    await mediaKit.openTracks(mList);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await mediaKit.jumpTrack(index);
  }

  // Direct Controls
  @override
  Future<void> play() async {
    await mediaKit.play();
  }

  @override
  Future<void> pause() async {
    await mediaKit.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await mediaKit.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    await mediaKit.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await mediaKit.previous();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await mediaKit.setPlaybackRate(speed);
  }

// dispose methods
  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await mediaKit.dispose();
    }
  }

  @override
  Future<void> stop() async {
    await mediaKit.stop();
    return super.stop();
  }
}
