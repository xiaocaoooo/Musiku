import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

import '../utool.dart';

class Debug extends StatefulWidget {
  const Debug({super.key});

  @override
  State<Debug> createState() => _DebugState();
}

class _DebugState extends State<Debug> {
  String outputText = 'Loading...\n';
  String cover = " ";

  @override
  void initState() {
    super.initState();
    ff();
  }

  Future<void> ff() async {
    final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();
    // const file = "/storage/emulated/0/MyMusic/miku/105558236.mp3";
    const file = "/storage/emulated/0/MyMusic/miku/201451969.flac";
    // final info = await _flutterFFprobe
    // .getMediaInformation("/storage/emulated/0/MyMusic/miku/105558293.flac");
    final info = await _flutterFFprobe.getMediaInformation(file);
    print("---START---");
    // print(info.getAllProperties()["format"]["tags"]["TITLE"]);
    print(info.getMediaProperties());
    print("---END---");
    final coverPath = (await getCover(file))??"null";
    setState(() {
      // outputText = info.getMediaProperties()?["tags"]["LYRICS"];
      // outputText = "${info.getMediaProperties()?["duration"]}\n${info.getMediaProperties()?["tags"]["title"]} - ${info.getMediaProperties()?["tags"]["artist"]}\n${info.getMediaProperties()?["tags"]["album"]}\n${info.getMediaProperties()?["tags"]["lyrics-eng"]}";
      outputText =
          "${info.getMediaProperties()?["filename"]}\n${info.getMediaProperties()?["duration"]}\n${info.getMediaProperties()?["tags"]["TITLE"]} - ${info.getMediaProperties()?["tags"]["ARTIST"]}\n${info.getMediaProperties()?["tags"]["ALBUM"]}\n${info.getMediaProperties()?["tags"]["LYRICS"]}";
      cover = coverPath;
    });
    // final meta=await getMusicMetadata("/storage/emulated/0/MyMusic/miku/250289526.mp3");
    // setState(() {
    //   outputText = "${meta?["duration"]}\n${meta?["title"]} - ${meta?["artist"]}\n${meta?["album"]}\n${meta?["lyrics"]}";
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(File(cover)),
            Text(cover),
            SelectableText(
              outputText,
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
              maxLines: null,
              textAlign: TextAlign.left,
            )
          ],
        ),
      ),
    );
  }
}
