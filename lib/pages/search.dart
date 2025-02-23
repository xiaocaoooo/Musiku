import 'package:flutter/material.dart';
import 'package:musiku/pages/search_result.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  // List<String> results = ["123", "456"];

  // void search() async {
  //   if (query == '') return;
  //   results = [];
  //   for (var music in Global.musicInfo.values) {
  //     if ("${music["title"]}${music["artist"]}${music["album"]}".contains(
  //         query)) {
  //       results.add(music["filePath"]);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                query = value;
              });
              // search();
            },
          ),
          Expanded(
            child: SearchResult(query: query),
          )
        ],
      ),
    );
  }
}
