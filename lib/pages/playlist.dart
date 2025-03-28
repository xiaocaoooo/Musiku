import 'package:flutter/material.dart';
import 'package:musiku/global.dart';
import 'package:musiku/music_info.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late ScrollController _scrollController;

  void _init() async {
    _scrollController.animateTo(Global.playingIndex * 50.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut); // 50.0 是每个列表项的高度（根据实际情况调整）
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(
          child: ReorderableListView.builder(
            scrollController: _scrollController,
            itemCount: Global.playlist.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                key: ValueKey(index),
                title: Container(
                  color: index == Global.playingIndex
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  child: MusicInfo(path: Global.playlist[index]),
                ),
                onTap: () {
                  setState(() {
                    Global.playingIndex = index;
                    Navigator.pushNamed(context, "/player",
                        arguments: Global.playlist[index]);
                  });
                },
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = Global.playlist.removeAt(oldIndex);
                Global.playlist.insert(newIndex, item);
                if (Global.playingIndex > oldIndex &&
                    Global.playingIndex <= newIndex) {
                  Global.playingIndex--;
                } else if (Global.playingIndex < oldIndex &&
                    Global.playingIndex > newIndex) {
                  Global.playingIndex++;
                } else if (Global.playingIndex == oldIndex) {
                  Global.playingIndex = newIndex;
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
