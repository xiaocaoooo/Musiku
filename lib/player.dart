import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiku/global.dart';

class Player extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  // mix in default seek callback implementations

  final player = AudioPlayer(); // e.g. just_audio
  bool playing = false;

  // The most common callbacks:
  Future<void> play() async {
    await player.play();
    playing = player.playing;
  }

  Future<void> pause() async {
    await player.pause();
    playing = player.playing;
  }

  Future<void> stop() async {
    await player.stop();
    playing = player.playing;
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
    playing = player.playing;
  }

  Future<void> previous() async {
    Global.playingIndex--;
    if (Global.playingIndex < 0) {
      Global.playingIndex = Global.playlist.length - 1;
    }
    await player.setUrl(Global.playlist[Global.playingIndex]);
    await player.play();
    playing = player.playing;
  }

  Future<void> next() async {
    Global.playingIndex++;
    if (Global.playingIndex >= Global.playlist.length) {
      Global.playingIndex = 0;
    }
    await player.setUrl(Global.playlist[Global.playingIndex]);
    await player.play();
    playing = player.playing;
  }
}
