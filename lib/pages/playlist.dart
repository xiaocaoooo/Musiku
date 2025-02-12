import 'package:flutter/material.dart';
import 'package:musiku/global.dart';
import 'package:musiku/utool.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(
          child: ReorderableListView.builder(
            itemCount: Global.playlist.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                key: ValueKey(index),
                title: index == Global.playingIndex
                    ? Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        Global.musicInfo[Global.playlist[index]]
                                                ?['title'] ??
                                            Global.playlist[index]
                                                .split('/')
                                                .last,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        )),
                                    Text(
                                        Global.musicInfo[Global.playlist[index]]
                                                ?['artist'] ??
                                            "",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer
                                              .withOpacity(.6),
                                        )),
                                  ]),
                            ),
                            Text(
                              Global.musicInfo[Global.playlist[index]]
                                          ?['duration'] !=
                                      null
                                  ? (Global.musicInfo[Global.playlist[index]]
                                              ?['duration'] !=
                                          0
                                      ? processDuration(Global
                                              .musicInfo[Global.playlist[index]]
                                          ?['duration'].toInt())
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
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      Global.musicInfo[Global.playlist[index]]
                                              ?['title'] ??
                                          Global.playlist[index]
                                              .split('/')
                                              .last,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      )),
                                  Text(
                                      Global.musicInfo[Global.playlist[index]]
                                              ?['artist'] ??
                                          "",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer
                                            .withOpacity(.6),
                                      )),
                                ]),
                          ),
                          Text(
                            Global.musicInfo[Global.playlist[index]]
                                        ?['duration'] !=
                                    null
                                ? (Global.musicInfo[Global.playlist[index]]
                                            ?['duration'] !=
                                        0
                                    ? processDuration(
                                        Global.musicInfo[Global.playlist[index]]
                                            ?['duration'])
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
                      ),
                onTap: () {
                  setState(() {
                    Global.playingIndex = index;
                    Navigator.pushNamed(context, "/player", arguments: Global.playlist[index]);
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
