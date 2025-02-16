import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:musiku/auto_scrolling_text.dart';
import 'package:musiku/global.dart';
import 'package:musiku/utool.dart';
import 'package:musiku/usersettings.dart';
import 'package:palette_generator/palette_generator.dart';

import '../lyric.dart';

class LyricPage extends StatefulWidget {
  LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  String path = "";
  String cover = "";
  String title = "";
  String artist = "";
  String album = "";
  String lyric = "";
  double duration = 0;
  double position = 0;
  int idx = 0;
  int lastIdx = 0;
  late Lyrics lyrics;
  List<dynamic> lrcs = [];
  List<dynamic> widgets = [];
  Color primaryColor = const Color(0xFF39C5BB);
  PaletteGenerator paletteGenerator =
      PaletteGenerator.fromColors([PaletteColor(const Color(0xFF39C5BB), 1)]);
  late ScrollController _scrollController;

  Future<void> initData() async {
    getMusicMetadata(path, cache: false);
    cover = Global.coverCache[path] ?? await getCover(path) ?? "";
    final meta = Global.musicInfo[path];
    title = meta?["title"] ?? path.split("/").last;
    artist = meta?["artist"] ?? "";
    album = meta?["album"] ?? "";
    duration = meta?["duration"].toDouble() ?? 0;
    setState(() {});
    lyric = await getLyrics(path);
    lyrics = Lyrics(lyric);
    paletteGenerator = (await getPaletteGeneratorFromImage(cover))!;
    primaryColor = paletteGenerator.dominantColor!.color;
    setState(() {});
  }

  Future<void> refresh({bool auto = false}) async {
    if (auto) {
      Future.delayed(const Duration(milliseconds: 50), () {
        refresh(auto: true);
      });
    }
    if (path != Global.playlist[Global.playingIndex]) {
      path = Global.playlist[Global.playingIndex];
      initData();
    }

    setState(() {
      position = Global.player.player.position.inSeconds.toDouble();
      duration =
          Global.player.player.duration?.inSeconds.toDouble() ?? duration;
      if (lyric != "") {
        widgets = [
          const SizedBox(
            height: 200,
          )
        ];
        lrcs = lyrics.lrcs;
        for (int i = 0; i < lrcs.length; i++) {
          if (lrcs[i].startTime <= position && position <= lrcs[i].endTime) {
            idx = i;
          }
          widgets.add(Lyric(
            lrcs[i],
            position,
          ));
        }
        if (lastIdx != idx) {
          print("idx:$idx");
          lastIdx = idx;
          _scrollController.animateTo(
            (48 * idx).toDouble(),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        // print("idx:$idx");
        // double progress = (position - widgets[idx].lrc.startTime) /
        //     (widgets[idx].lrc.endTime - widgets[idx].lrc.startTime);
        // widgets = [
        //   // ClipRRect(
        //   //     clipBehavior: Clip.hardEdge,
        //   //     child: Container(height: max(48 * min(1-progress, 1), 0), child: widgets[idx - 5])),
        //   ...widgets.sublist(max(idx - 5, 0))
        // ];
      }
    });
  }

  void _init() {
    _scrollController = ScrollController();
    path = Global.playlist[Global.playingIndex];
    initData();
    refresh(auto: true);
    // Timer.periodic(const Duration(milliseconds: 0), (timer) {
    //   refresh(auto: true);
    // });
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPersistentFrameCallback((_) {
    //   refresh();
    // });
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        cover != ""
            ? Image.file(
                File(cover),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Container(),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        Container(
          child: Column(
            children: [
              // SizedBox(
              //   height: MediaQuery
              //       .of(context)
              //       .padding
              //       .top,
              // ),
              Expanded(
                  child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: widgets.length,
                itemBuilder: (context, index) {
                  return widgets[index];
                },
              )),
            ],
          ),
        ),
        ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
            clipBehavior: Clip.hardEdge,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: SizedBox(
                  height: 170,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 28),
                        child: SizedBox(
                          height: 100,
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(16.0)),
                                    ),
                                    child: cover != ""
                                        ? Image.file(
                                            File(cover),
                                            width: 100,
                                            height: 100,
                                          )
                                        : Image.asset(
                                            "assets/images/default_player_cover.jpg"),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  // 这里设置 Column 的 mainAxisAlignment 为 center 实现上下居中
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoScrollingText(
                                        text: title,
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      AutoScrollingText(
                                        text: artist,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            )),
      ]),
    );
  }
}
