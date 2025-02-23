import 'dart:io';

import 'package:flutter/material.dart';
import 'package:musiku/utool.dart';

import 'global.dart';

class MusicInfo extends StatefulWidget {
  String path;

  MusicInfo({super.key, required this.path});

  @override
  State<MusicInfo> createState() => _MusicInfoState();
}

class _MusicInfoState extends State<MusicInfo> {
  void _init() async {
    if (!Global.musicInfo.containsKey(widget.path)) {
      await getMusicMetadata(widget.path);
    }
    if (!Global.coverCache.containsKey(widget.path)) {
      await getCover(widget.path);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Global.coverCache.containsKey(widget.path)
                ? Image.file(File(Global.coverCache[widget.path]!),
                    width: 50, height: 50)
                : Image.asset("assets/images/default_player_cover.jpg",
                    width: 50, height: 50)),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                Global.musicInfo[widget.path]?['title'] ??
                    widget.path.split('/').last,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                )),
            Text(Global.musicInfo[widget.path]?['artist'] ?? "",
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(.6),
                )),
          ]),
        ),
        Text(
          Global.musicInfo[widget.path]?['duration'] != null
              ? (Global.musicInfo[widget.path]?['duration'] != 0
                  ? processDuration(
                      Global.musicInfo[widget.path]?['duration'].toInt())
                  : "")
              : "",
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSecondaryContainer
                .withOpacity(.6),
          ),
        ),
      ],
    );
  }
}
