import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:vinyl/core/background/background_service.dart';
import 'package:vinyl/core/services/media_record.dart';
import 'package:vinyl/core/services/player_interface.dart';

class MobilePlayerController extends PlayerInterface {
  MobilePlayerController({required this.audioHandler}) {
    init();
  }

  final MediaKitBackgroundPlayer audioHandler;

  final idGen = Random();

  void init() {
    try {
      _listenToChangesInPlaylist();
      _listenToPlaybackState();
      _listenToCurrentPosition();
      _listenToBufferedPosition();
      _listenToTotalDuration();
      _listenToChangesInSong();
    } catch (e) {
      debugPrint('error initializing player-controller $e');
    }
  }

  final queue = ValueNotifier<List<String>>([]);

  void _listenToChangesInPlaylist() {
    audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        queue.value = [];
        currentSongTitle.value = '';
      } else {
        // keep this in a separate variable to avoid
        // weird bug with ui not update
        final newList = playlist.map((item) => item.title).toList();
        queue.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    audioHandler.playbackState.listen((playbackState) async {
      if (queue.value.isNotEmpty) {
        isStopped.value = false;
        final isPlaying = playbackState.playing;
        final processingState = playbackState.processingState;

        if (processingState == AudioProcessingState.loading ||
            processingState == AudioProcessingState.buffering) {
          playButton.value = ButtonState.loading;
        }
        // !(processingState == AudioProcessingState.idle)) is here because
        // when stop is called from audio service process-state becomes idle
        // so we can move to stop in controller
        else if (!isPlaying &&
            !(processingState == AudioProcessingState.idle)) {
          playButton.value = ButtonState.paused;
        } else if (processingState == AudioProcessingState.ready) {
          playButton.value = ButtonState.playing;
        } else {
          await stop();
        }
      } else {
        isStopped.value = true;
        playButton.value = ButtonState.paused;
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      progressState.value = progressState.value.copyWith(
        current: position,
      );
    });
  }

  void _listenToBufferedPosition() {
    audioHandler.playbackState.listen((playbackState) {
      progressState.value = progressState.value.copyWith(
        buffered: playbackState.bufferedPosition,
      );
    });
  }

  void _listenToTotalDuration() {
    audioHandler.mediaItem.listen((mediaItem) {
      progressState.value = progressState.value.copyWith(
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitle.value = mediaItem?.title ?? '';
      currentImage.value =
          mediaItem?.artUri.toString() ?? Icons.music_note.toString();
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = audioHandler.mediaItem.value;
    final playlist = audioHandler.queue.value;

    if (playlist.length < 2 || mediaItem == null) {
      isFirstSong.value = true;
      isLastSong.value = true;
    } else {
      isFirstSong.value = playlist.first == mediaItem;
      isLastSong.value = playlist.last == mediaItem;
    }
  }

  @override
  Future<void> loadMedia(List<MediaRecord> input, {
    Duration listenedPos = Duration.zero,
    int trackIndex = 0,
  }) async {
    await audioHandler.loadMedia(input);
    await audioHandler.skipToQueueItem(trackIndex);
    await audioHandler.seek(listenedPos);
  }

  @override
  Future<void> play() async {
    await audioHandler.play();
  }

  @override
  Future<void> pause() async {
    await audioHandler.pause();
  }

  @override
  Future<void> seek(Duration position, {int? trackIndex}) async {
    await audioHandler.seek(position);
  }

  @override
  Future<void> seekForward(Duration positionOffset) async {
    final seekVal = progressState.value.current + positionOffset;
    if (seekVal >= progressState.value.total) {
      await audioHandler.seek(progressState.value.total);
      return;
    }
    await audioHandler.seek(seekVal);
  }

  @override
  Future<void> seekBackward(Duration positionOffset) async {
    final seekVal = progressState.value.current - positionOffset;
    if (seekVal <= Duration.zero) {
      await audioHandler.seek(Duration.zero);
      return;
    }
    await audioHandler.seek(seekVal);
  }

  @override
  Future<void> previous() async => audioHandler.skipToPrevious();

  @override
  Future<void> next() async => audioHandler.skipToNext();

  @override
  Future<void> setSpeed() async => audioHandler.setSpeed(playbackSpeed.value);

  @override
  Future<void> dispose() async {
    await stop();
    await audioHandler.customAction('dispose');
  }

  @override
  Future<void> stop() async {
    await audioHandler.stop();
    isStopped.value = true;
    queue.value = [];
    currentSongTitle.value = '';
    currentImage.value = '';
  }

  @override
  Future<void> skipToTrack({
    Duration position = Duration.zero,
    int trackIndex = 0,
  }) async {
    await audioHandler.skipToQueueItem(trackIndex);
    await seek(position);
  }
}
