import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musiku/auto_scrolling_text.dart';
import 'package:musiku/global.dart';
import 'package:musiku/utool.dart';
import 'package:musiku/usersettings.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:wakelock/wakelock.dart';

import '../android_native.dart';
import '../lyric.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage>
    with SingleTickerProviderStateMixin {
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
  List<Map<String, dynamic>>? lyrics;
  List<dynamic> lrcs = [];
  List<dynamic> widgets = [];
  Color primaryColor = const Color(0xFF39C5BB);
  PaletteGenerator paletteGenerator =
      PaletteGenerator.fromColors([PaletteColor(const Color(0xFF39C5BB), 1)]);
  ThemeData? theme;
  int themeIndex = 0;

  // late ScrollController _scrollController;
  bool exist = true;
  late AnimationController _controller;
  late ScrollController controller;

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
    lyrics = Lyrics(lyric).lrcs;
    paletteGenerator = (await getPaletteGeneratorFromImage(cover))!;
    primaryColor = paletteGenerator.dominantColor!.color;
    theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: MediaQuery.of(context).platformBrightness),
      useMaterial3: true,
    );
    themeIndex = await UserSettings.getTheme();
    setState(() {});
  }

  Future<void> refresh({bool auto = false}) async {
    try {
      setState(() {});
      // print("refresh");
      if (auto && mounted) {
        Future.delayed(const Duration(milliseconds: 50), () {
          refresh(auto: true);
        });
      }
      if (path != Global.playlist[Global.playingIndex]) {
        path = Global.playlist[Global.playingIndex];
        initData();
      }
      if (mounted) {
        position =
            Global.player.player.position.inMilliseconds.toDouble() / 1000;
        duration =
            Global.player.player.duration!.inMilliseconds.toDouble() / 1000;
        lrcs = lyrics!;
        Global.lrcs = lrcs;
        for (int i = 0; i < lrcs.length; i++) {
          if (i != 0 && i != lrcs.length - 1) {
            if (lrcs[i - 1]["endTime"] <= position &&
                lrcs[i + 1]["startTime"] >= position) {
              idx = i;
            }
          }
          if (lrcs[i]["startTime"] <= position &&
              position <= lrcs[i]["endTime"]) {
            idx = i;
          }
        }
        if (lastIdx != idx) {
          lastIdx = idx;
          AndroidNativeCode.sendLyric(
              lrcs[idx]["content"].map((e) => e["text"]).join());
          controller.animateTo(
            // max(31 * idx, 0).toDouble(),
            (controller.position.maxScrollExtent) * (idx / Global.lrcs.length),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        // if (lyric != "") {
        //   widgets = [
        //     const SizedBox(
        //       height: 200,
        //     )
        //   ];
        //   lrcs = lyrics.lrcs;
        //   for (int i = 0; i < lrcs.length; i++) {
        //     if (lrcs[i].startTime <= position && position <= lrcs[i].endTime) {
        //       idx = i;
        //     }
        //     widgets.add(Lyric(
        //       lrcs[i],
        //       position,
        //     ));
        //   }
        //   if (lastIdx != idx) {
        //     print("idx:$idx");
        //     lastIdx = idx;
        //     _scrollController.animateTo(
        //       (48 * idx).toDouble(),
        //       duration: const Duration(milliseconds: 500),
        //       curve: Curves.easeInOut,
        //     );
        //   }
        //   // print("idx:$idx");
        //   // double progress = (position - widgets[idx].lrc.startTime) /
        //   //     (widgets[idx].lrc.endTime - widgets[idx].lrc.startTime);
        //   // widgets = [
        //   //   // ClipRRect(
        //   //   //     clipBehavior: Clip.hardEdge,
        //   //   //     child: Container(height: max(48 * min(1-progress, 1), 0), child: widgets[idx - 5])),
        //   //   ...widgets.sublist(max(idx - 5, 0))
        //   // ];
        // }
        try {
          setState(() {});
        } catch (e) {
          //
        }
      }
    } catch (e) {
      //
    }
  }

  Future<void> _init() async {
    // _scrollController = ScrollController();
    controller = ScrollController();
    path = Global.playlist[Global.playingIndex];
    await initData();
    // refresh();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.addListener(() {
      refresh();
    });
    _controller.repeat();
    // refresh(auto: true);
    // Timer.periodic(const Duration(milliseconds: 0), (timer) {
    //   refresh(auto: true);
    // });
  }

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 3), () {
    //   refresh();
    // });
    // refresh(auto: true);
    // WidgetsBinding.instance.addPersistentFrameCallback((_) {
    //   refresh();
    // });
    Wakelock.enable();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    Wakelock.disable();
    super.dispose();
    // Timer.periodic(const Duration(milliseconds: 50), (timer) {
    //   refresh(auto: true);
    // }).cancel();
    // exist=false;
  }

  @override
  Widget build(BuildContext context) {
    // print("123index length ${lyrics.lrcs.length}");
    return Stack(children: [
      // cover != ""
      //     ? Image.file(
      //         File(cover),
      //         fit: BoxFit.cover,
      //         width: double.infinity,
      //         height: double.infinity,
      //       )
      //     : Container(),
      // BackdropFilter(
      //   filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
      //   child: Container(
      //     color: Colors.black.withOpacity(0.1),
      //   ),
      // ),
      LyricsView(
        lyrics: lyrics ?? [],
        time: position,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        paddingTop: 200,
        controller: controller,
        secondaryColor: (themeIndex == 1
                ? Theme.of(context).colorScheme.onBackground
                : (theme?.colorScheme.onBackground ?? Colors.white))
            .withOpacity(0.5),
        primaryColor: (themeIndex == 1
            ? Theme.of(context).colorScheme.primary
            : (theme?.colorScheme.primary ?? Colors.white)),
      ),
      ClipRRect(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16)),
          clipBehavior: Clip.hardEdge,
          // child: Container(
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
                            // Container(
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(16),
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Colors.black.withOpacity(0.2),
                            //         spreadRadius: 5,
                            //         blurRadius: 7,
                            //         offset: const Offset(0, 3),
                            //       ),
                            //     ],
                            //   ),
                            //   child: ClipRRect(
                            //     borderRadius: const BorderRadius.all(
                            //         Radius.circular(16.0)),
                            //     clipBehavior: Clip.hardEdge,
                            //     child: Container(
                            //       decoration: const BoxDecoration(
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(16.0)),
                            //       ),
                            //       child: cover != ""
                            //           ? Image.file(
                            //               File(cover),
                            //               width: 100,
                            //               height: 100,
                            //             )
                            //           : Image.asset(
                            //               "assets/images/default_player_cover.jpg"),
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(
                              width: 100,
                              height: 100,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                // 这里设置 Column 的 mainAxisAlignment 为 center 实现上下居中
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoScrollingText(
                                      text: title,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: (themeIndex == 1
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onBackground
                                                : (theme?.colorScheme
                                                        .onBackground ??
                                                    Colors.white))
                                            .withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AutoScrollingText(
                                      text: artist,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: (themeIndex == 1
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onBackground
                                                : (theme?.colorScheme
                                                        .onBackground ??
                                                    Colors.white))
                                            .withOpacity(0.6),
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
    ]);
  }
}
