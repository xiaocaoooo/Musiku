import 'package:flutter/services.dart';

class AndroidNativeCode {
  // 创建平台通道，名称需与 Android 端一致
  static const platform = MethodChannel('lyric_sender');

  static Future<void> sendLyric(String lyric) async {
    // 调用平台方法，参数为要发送的歌词
    await platform.invokeMethod('sendLyric', {'lyric': lyric});
  }
}