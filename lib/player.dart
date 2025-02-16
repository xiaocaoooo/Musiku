import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiku/global.dart';

class Player extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  // mix in default seek callback implementations

  final player = AudioPlayer(); // e.g. just_audio

  void initState() {
    player.playbackEventStream.listen((event) {
      print("playerevent:$event");
      switch (event.processingState) {
        //   播放结束
        case ProcessingState.completed:
          next();
          break;
        default:
          break;
      }
    });
  }

  // The most common callbacks:
  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> previous() async {
    Global.playingIndex--;
    if (Global.playingIndex < 0) {
      Global.playingIndex = Global.playlist.length - 1;
    }
    await player.setUrl(Global.playlist[Global.playingIndex]);
    await player.play();
  }

  Future<void> next() async {
    Global.playingIndex++;
    if (Global.playingIndex >= Global.playlist.length) {
      Global.playingIndex = 0;
    }
    await player.setUrl(Global.playlist[Global.playingIndex]);
    await player.play();
  }
}
