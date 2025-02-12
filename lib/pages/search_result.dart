import 'package:flutter/material.dart';
import 'package:musiku/utool.dart';

import '../global.dart';

class SearchResult extends StatefulWidget {
  final String query;

  const SearchResult({super.key, required this.query});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  List<String> results = [];

  void search() async {
    if (widget.query == '') results = Global.musicInfo.keys.toList();
    results = [];
    for (var music in Global.musicInfo.values) {
      if ("${music["title"]}${music["artist"]}${music["album"]}"
          .contains(widget.query)) {
        results.add(music["filePath"]);
      }
    }
    // print("114514$results");
  }

  @override
  Widget build(BuildContext context) {
    search();
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.query),
      // ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            Global.musicInfo[results[index]]?['title'] ??
                                results[index].split('/').last,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            )),
                        Text(Global.musicInfo[results[index]]?['artist'] ?? "",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withOpacity(.6),
                            )),
                      ]),
                ),
                Text(
                  Global.musicInfo[results[index]]?['duration'] != null
                      ? (Global.musicInfo[results[index]]?['duration'] != 0
                          ? processDuration(
                              Global.musicInfo[results[index]]?['duration']
                                  .toInt())
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
              Global.playlist = results;
              Global.playingIndex = index;
              Navigator.pushNamed(context, "/player", arguments: results[index]);
            },
          );
        },
      ),
    );
  }
}
