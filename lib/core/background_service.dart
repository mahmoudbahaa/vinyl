import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import 'package:vinyl/core/mediakit_player.dart';

Future<MediaKitBackgroundPlayer> initBackgroundAudio(
    MediaKitPlayer mediaKit,AudioServiceConfig audioConfig) async {
  return AudioService.init(
    builder: () => MediaKitBackgroundPlayer(player: mediaKit),
    config: audioConfig,
  );
}
//
class MediaKitBackgroundPlayer extends BaseAudioHandler {

  MediaKitBackgroundPlayer({required this.player}) {
    try {
      initListeners();
    } catch (e) {
      debugPrint('Error initializing audio handler: $e');
    }
  }
  late final MediaKitPlayer player;

  MediaKitPlayer get mediaKit => player;

  void initListeners() {
    _notifyIsPlaying();
    listenIsBuffering();
    listenToIsCompleted();
    _listenToPosition();
    _listenToBufferedPosition();
    _listenForDurationChanges();
    _listenToCurrentMedia();
    _listenToPlaybackSpeed();
  }

  final processMap = const {
    ProcessingState.idle: AudioProcessingState.idle,
    ProcessingState.loading: AudioProcessingState.loading,
    ProcessingState.buffering: AudioProcessingState.buffering,
    ProcessingState.ready: AudioProcessingState.ready,
    ProcessingState.completed: AudioProcessingState.completed,
  };

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

  // playback state
  void _notifyIsPlaying() {
    player.stream.playing.listen((bool playing) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
          },
          androidCompactActionIndices: const [0, 1, 3],
          playing: playing,
          processingState: processMap[player.state.buffering
              ? ProcessingState.buffering
              : ProcessingState.ready]!,
        ),
      );
    });
  }

  void listenIsBuffering() {
    player.stream.buffering.listen((bool buffering) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: processMap[
          buffering ? ProcessingState.buffering : ProcessingState.ready]!,
        ),
      );
    });
  }

  void listenToIsCompleted() {
    player.stream.completed.listen((bool completed) {
      final playerState = player.mediaKit.state;

      final currentIndex = playerState.playlist.index;
      final playlistLastIndex = playerState.playlist.medias.length - 1;
      final playListComplete = currentIndex == playlistLastIndex;

      playbackState.add(
        playbackState.value.copyWith(
          processingState: processMap[playListComplete
              ? ProcessingState.idle
              : ProcessingState.completed]!,
        ),
      );
    });
  }

  // playback positions
  void _listenToPosition() {
    // player.stream.position.listen((pos) {
    //   playbackState.add(
    //     playbackState.value.copyWith(),
    //   );
    // });
  }

  void _listenToBufferedPosition() {
    player.stream.buffer.listen((bufferedPosition) {
      playbackState.add(
        playbackState.value.copyWith(bufferedPosition: bufferedPosition),
      );
    });
  }

  void _listenForDurationChanges() {
    player.stream.duration.listen((duration) {
      final index = player.state.playlist.index;
      final newQueue = queue.value;
      if (newQueue.isEmpty) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;

      queue.value = newQueue;
      mediaItem.add(newMediaItem);
    });
  }

  // media changes
  void _listenToCurrentMedia() {
    player.stream.playlist.listen((playlist) {
      // update queue
      // queue.value = playlist.medias.map(_convertToMediaItem).toList();
      final index = playlist.index;
      playbackState.add(
        playbackState.value.copyWith(queueIndex: index),
      );
      final currentQueue = queue.value;
      // update current playing item
      mediaItem.add(currentQueue[index]);
    });
  }

  // playback other states
  void _listenToPlaybackSpeed() {
    player.stream.rate.listen((speed) {
      playbackState.add(
        playbackState.value.copyWith(speed: speed),
      );
    });
  }

  // queue controls
  void clearQueue() {
    while (queue.value.isNotEmpty) {
      queue.value.removeLast();
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // TODO: implement addQueueItems

  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await mediaKit.jumpTrack(index);
  }

  // Direct Controls
  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    await player.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await player.previous();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await player.setPlaybackRate(speed);
  }

// dispose methods
  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await player.dispose();
    }
  }

  @override
  Future<void> stop() async {
    await player.stop();
    return super.stop();
  }
}

enum ProcessingState {
  idle,
  loading,
  buffering,
  ready,
  completed,
}
