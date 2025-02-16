import 'package:flutter/material.dart';
import 'package:musiku/music_info.dart';
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
    sort();
  }

  void sort() {
    results.sort((a, b) {
      final lastModifiedA = Global.musicInfo[a]["title"];
      final lastModifiedB = Global.musicInfo[b]["title"];
      return lastModifiedA.compareTo(lastModifiedB);
    });
  }

  @override
  void initState() {
    super.initState();
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
            title: MusicInfo(path: results[index]),
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
