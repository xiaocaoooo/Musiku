import 'dart:isolate';
import 'android_native.dart';
import 'global.dart';

Future<void> backgroundTask(SendPort sendPort) async {
  int idx = -1;
  int lastIdx = -1;
  while (true) {
    // print("background task");
    final List<dynamic> lrcs = Global.lrcs;
    final double position =
        Global.player.player.position.inMilliseconds.toDouble() / 1000;
    for (int i = 0; i < lrcs.length; i++) {
      if (i != 0 && i != lrcs.length - 1) {
        if (lrcs[i - 1]["endTime"] <= position &&
            lrcs[i + 1]["startTime"] >= position) {
          idx = i;
        }
      }
      if (lrcs[i]["startTime"] <= position && position <= lrcs[i]["endTime"]) {
        idx = i;
      }
    }
    if (idx != lastIdx) {
      AndroidNativeCode.sendLyric(lrcs[idx]["content"].map((e) => e["text"]).join());
      lastIdx = idx;
    }
    // print(lrcs[idx]["content"].map((e) => e["text"]).join());
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
