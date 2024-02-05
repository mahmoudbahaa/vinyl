// ignore_for_file: implementation_imports

import 'package:media_kit/media_kit.dart';

class MediaKitPlayer {
  MediaKitPlayer({required this.mediaKit});

  late final Player mediaKit;
  static const zeroTime = Duration.zero;

  PlayerStream get stream => mediaKit.stream;

  PlayerState get state => mediaKit.state;

  Future<void> openTracks(
      List<Media> mediaItems,
      ) async {
    final playlist = Playlist(mediaItems);
    await mediaKit.open(playlist, play: false);
  }

  Future<void> play() async {
    await mediaKit.play();
  }

  Future<void> pause() async {
    await mediaKit.pause();
  }

  Future<void> stop() async {
    await mediaKit.stop();
  }

  Future<void> next() async {
    if (mediaKit.state.playing) {
      await pause();
    }
    await mediaKit.next();
  }

  Future<void> previous() async {
    if (mediaKit.state.playing) {
      await pause();
    }
    await mediaKit.previous();
  }

  Future<void> skipBackwards(Duration offset) async {
    var skipVal = mediaKit.state.position - offset;
    if (skipVal <= zeroTime) {
      skipVal = zeroTime;
    }
    await seek(skipVal);
  }

  Future<void> skipForwards(Duration offset) async {
    var skipVal = mediaKit.state.position + offset;
    if (mediaKit.state.duration <= skipVal) {
      skipVal = mediaKit.state.duration;
    }

    await seek(skipVal);
  }

  Future<void> jumpTrack(int index) async {
    await mediaKit.jump(index);
  }

  Future<void> seek(Duration position) async {
    await mediaKit.seek(position);
  }

  Future<void> setPlaybackRate(double rate) async {
    await mediaKit.setRate(rate);
  }

  Future<void> setVolume(double volume) async {
    await mediaKit.setVolume(volume);
  }

  Future<void> setLoopMode(PlaylistMode mode) async {
    await mediaKit.setPlaylistMode(mode);
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setShuffleMode(bool shuffle) async {
    await mediaKit.setShuffle(shuffle);
  }

  Future<void> dispose() async {
    await mediaKit.dispose();
  }
}
