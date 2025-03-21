import 'package:audio_service/audio_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiku/global.dart';
import 'package:musiku/userdata.dart';
import 'package:musiku/utool.dart';

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
    setInfo();
    playing = player.playing;
  }

  Future<void> pause() async {
    await player.pause();
    setInfo();
    playing = player.playing;
  }

  Future<void> stop() async {
    await player.stop();
    setInfo();
    playing = player.playing;
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
    setInfo();
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

  void setFilePath(String filePath) {
    player.setFilePath(filePath);
    player.play();
    setInfo();
  }

  Future<void> setInfo() async {
    Map<String, dynamic> info = {
      "title": Global.musicInfo[Global.playlist[Global.playingIndex]]["title"],
      "artist": Global.musicInfo[Global.playlist[Global.playingIndex]]["artist"],
      "album": Global.musicInfo[Global.playlist[Global.playingIndex]]["album"],
      "duration": Global.musicInfo[Global.playlist[Global.playingIndex]]["duration"],
      "filePath": Global.musicInfo[Global.playlist[Global.playingIndex]]["filePath"],
      "coverUrl": await getCover(Global.musicInfo[Global.playlist[Global.playingIndex]]["filePath"]),
      "startTime": (DateTime.now().millisecondsSinceEpoch -
          player.position.inMilliseconds.toDouble()) /
          1000,
      "playing": player.playing,
      "lyric": Global.lrcs,
    };
    // Fluttertoast.showToast(
    //     msg: "这是一个 Toast 消息", // Toast 消息内容
    //     toastLength: Toast.LENGTH_SHORT, // Toast 显示时长
    //     gravity: ToastGravity.CENTER, // Toast 显示位置
    // );
    // UserData("musicInfo.json").set(Global.musicInfo[Global.playlist[Global.playingIndex]]);
    UserData("musicInfo.json").set(info);
  }
}
