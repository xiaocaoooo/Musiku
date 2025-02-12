import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:musiku/utool.dart';

class Debug extends StatefulWidget {
  const Debug({super.key});

  @override
  State<Debug> createState() => _DebugState();
}

class _DebugState extends State<Debug> {
  final filePath = "/storage/emulated/0/MyMusic/miku/203776471.mp3";

  // 新增一个异步方法来获取元数据
  Future<Map<String, dynamic>?> _getLyrics() async {
    final metadata = await getMusicMetadata(filePath);
    // final player = AudioPlayer();
    // final metadata = {
    //   "duration":
    //       (await player.setFilePath(filePath) as Duration).inMilliseconds,
    // };
    return metadata;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: Center(
        // 使用 FutureBuilder 来处理异步操作
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getLyrics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return SingleChildScrollView(
                // 当歌词内容超出屏幕时，允许垂直滚动
                child: Text(snapshot.data.toString()),
              );
            }
          },
        ),
      ),
    );
  }
}
