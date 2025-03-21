import 'dart:io';

import 'package:flutter/material.dart';

import '../const.dart';
import '../usersettings.dart';
import '../utool.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final List<String> _musicList = [];
  int _processedMusicCount = 0; // 已处理的音乐文件数量
  int exitNumber = 6;

  Future<void> _init() async {
    final List<String> folders = await UserSettings.getFolders();
    for (var folder in folders) {
      final directory = Directory(folder);
      final entities = await directory.list().toList();
      final ml = entities
          .where((entity) => FileSystemEntity.isFileSync(entity.path))
          .map((entity) => entity.path)
          .toList();
      for (var music in ml) {
        _musicList.add(music);
      }
    }
    setState(() {});
    for (var folder in folders) {
      final directory = Directory(folder);
      final entities = await directory.list().toList();
      final ml = entities
          .where((entity) => FileSystemEntity.isFileSync(entity.path))
          .map((entity) => entity.path)
          .toList();
      for (var music in ml) {
        // await Future.delayed(const Duration(milliseconds: 10));
        _processSingleMusic(music);
      }
    }
    setState(() {});
  }

  Future<void> _processSingleMusic(String music) async {
    // final flag = (await UserSettings.getMusicList()).contains(music);
    // await getCover(music);
    // await getMusicMetadata(music);
    await getMusicMetadata(music);
    setState(() {
      _processedMusicCount++; // 增加已处理的音乐文件数量
    });
    print("musiclist: $music ($_processedMusicCount/${_musicList.length})");
    if (_processedMusicCount >= _musicList.length) {
      exit();
    }
    // if (!flag) {
    //   _sortMusicList();
    // }
    // setState(() {}); // 更新界面以显示元数据
  }

  Future<void> exit() async {
    exitNumber--;
    setState(() {});
    if (exitNumber == 0) {
      Navigator.of(context).pop();
    }
    Future.delayed(const Duration(seconds: 1), () {
      exit();
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    if (_musicList.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              Const.index,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ));
    }
    if (_processedMusicCount >= _musicList.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            Const.index,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
        ),
        body: Center(
          child: Text(
            '处理完成，即将退出 ($exitNumber)',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(
        Const.index,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: _processedMusicCount /
                  (_musicList.length != 0 ? _musicList.length : 1),
            ),
            const SizedBox(height: 16),
            Text(
                '$_processedMusicCount/${(_musicList.length != 0 ? _musicList.length : "NaN")}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
          ],
        ),
      ),
    );
  }
}
