import 'package:flutter/material.dart';
import 'dart:io';
import 'package:musiku/const.dart';
import 'package:musiku/global.dart';
import 'package:musiku/usersettings.dart';
import '../music_info.dart';

class MusicListPage extends StatefulWidget {
  // 添加 path 参数
  final String path;

  const MusicListPage({super.key, required this.path});

  @override
  State<MusicListPage> createState() => _MusicListPageState();
}

class _MusicListPageState extends State<MusicListPage> {
  final List<String> _musicList = [];

  Future<void> _init() async {
    if (widget.path == Const.all) {
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
          File file = File(music);
          Global.musicLastModified[music] =
              file.lastModifiedSync().millisecondsSinceEpoch;
        }
      }
    } else {
      try {
        final directory = Directory(widget.path);
        final entities = await directory.list().toList();
        final ml = entities
            .where((entity) => FileSystemEntity.isFileSync(entity.path))
            .map((entity) => entity.path)
            .toList();
        for (var music in ml) {
          _musicList.add(music);
          File file = File(music);
          Global.musicLastModified[music] =
              file.lastModifiedSync().millisecondsSinceEpoch;
        }
      } catch (e) {
        // print('Error: $e');
      }
    }
    _sortMusicList();
    // if (widget.path == Const.all) {
    //   final List<String> folders = await UserSettings.getFolders();
    //   for (var folder in folders) {
    //     final directory = Directory(folder);
    //     final entities = await directory.list().toList();
    //     final ml = entities
    //         .where((entity) => FileSystemEntity.isFileSync(entity.path))
    //         .map((entity) => entity.path)
    //         .toList();
    //     for (var music in ml) {
    //       // await Future.delayed(const Duration(milliseconds: 10));
    //       _processSingleMusic(music);
    //     }
    //   }
    // } else {
    //   try {
    //     final directory = Directory(widget.path);
    //     final entities = await directory.list().toList();
    //     final ml = entities
    //         .where((entity) => FileSystemEntity.isFileSync(entity.path))
    //         .map((entity) => entity.path)
    //         .toList();
    //     for (var music in ml) {
    //       // await Future.delayed(const Duration(milliseconds: 10));
    //       _processSingleMusic(music);
    //     }
    //   } catch (e) {
    //     // print('Error: $e');
    //   }
    // }
    // 排序操作
    _sortMusicList();
    setState(() {});
  }

  void _sortMusicList() {
    _musicList.sort((a, b) {
      // swap
      // final tmp = a;
      // a = b;
      // b = tmp;
      // final lastModifiedA = Global.musicInfo[a]?["lastModified"];
      // final lastModifiedB = Global.musicInfo[b]?["lastModified"];
      final lastModifiedA = Global.musicLastModified[b];
      final lastModifiedB = Global.musicLastModified[a];

      if (lastModifiedA == null && lastModifiedB == null) {
        return 0;
      } else if (lastModifiedA == null) {
        return -1;
      } else if (lastModifiedB == null) {
        return 1;
      }

      return lastModifiedA.compareTo(lastModifiedB);
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    // if (_processedMusicCount < _musicList.length) {
    //   return Scaffold(
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           CircularProgressIndicator(
    //             value: _processedMusicCount / _musicList.length,
    //           ),
    //           const SizedBox(height: 16),
    //           Text('$_processedMusicCount/${_musicList.length}'),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    return Scaffold(
      body: ListView.builder(
        itemCount: _musicList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: MusicInfo(path: _musicList[index]),
            onTap: () {
              Global.playlist = _musicList;
              Global.playingIndex = index;
              Navigator.pushNamed(context, "/player",
                  arguments: _musicList[index]);
              setState(() {});
              // Navigator.pushNamed(context, "/player",
              //     arguments: _musicList[index]);
            },
          );
        },
      ),
    );
  }
}
