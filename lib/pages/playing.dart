import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:musiku/auto_scrolling_text.dart';
import 'package:musiku/global.dart';
import 'package:musiku/utool.dart';
import 'package:musiku/usersettings.dart';
import 'package:palette_generator/palette_generator.dart';

import '../lyric.dart';

class PlayingPage extends StatefulWidget {
  final String? path;

  const PlayingPage({super.key, this.path});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage>
    with TickerProviderStateMixin {
  String path = "";
  String cover = "";
  String title = "";
  String artist = "";
  String album = "";
  double duration = 0;
  double position = 0;
  double scale = 1;
  ThemeData? theme;
  int themeIndex = 0;

  Color primaryColor = const Color(0xFF39C5BB);
  PaletteGenerator paletteGenerator =
      PaletteGenerator.fromColors([PaletteColor(const Color(0xFF39C5BB), 1)]);

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  Future<void> initData() async {
    getMusicMetadata(path, cache: false);
    cover = await getCover(path) ?? "";
    final meta = Global.musicInfo[path];
    title = meta?["title"] ?? path.split("/").last;
    artist = meta?["artist"] ?? "";
    album = meta?["album"] ?? "";
    duration = meta?["duration"].toDouble() ?? 0;
    paletteGenerator = (await getPaletteGeneratorFromImage(cover))!;
    primaryColor = paletteGenerator.dominantColor!.color;
    theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: MediaQuery.of(context).platformBrightness),
      useMaterial3: true,
    );
    themeIndex = await UserSettings.getTheme();
    Global.lrcs = Lyrics(await getLyrics(path)).lrcs;
    Global.lightThemeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor, brightness: Brightness.light),
      brightness: Brightness.light,
      useMaterial3: true,
    );
    Global.darkThemeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor, brightness: Brightness.dark),
      brightness: Brightness.dark,
      useMaterial3: true,
    );
    setState(() {});
  }

  Future<void> refresh({bool auto = false}) async {
    if (path != Global.playlist[Global.playingIndex]) {
      path = Global.playlist[Global.playingIndex];
      initData();
    }
    position = Global.player.player.position.inSeconds.toDouble();
    duration = Global.player.player.duration?.inSeconds.toDouble() ?? duration;
    setState(() {});
    if (auto && mounted) {
      Future.delayed(
          const Duration(milliseconds: 500), () => refresh(auto: true));
    }
  }

  Future<void> setScale(double value) async {
    _scaleController.reset();
    _scaleAnimation = Tween<double>(begin: scale, end: value).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
    setState(() {
      scale = value;
    });
    await _scaleController.forward();
  }

  void _init() {
    path = Global.playlist[Global.playingIndex];
    initData();
    // if (widget.path != null) {
    //   Global.player.setFilePath(widget.path!);
    //   Global.player.play();
    // }
    refresh(auto: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: scale, end: scale).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Builder(
        builder: (BuildContext context) {
          double screenHeight = MediaQuery.of(context).size.height;
          return Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.18),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            clipBehavior: Clip.hardEdge,
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: cover != ""
                                  ? Image.file(
                                      File(cover),
                                      width: 300,
                                      height: 300,
                                    )
                                  : Image.asset(
                                      "assets/images/default_player_cover.jpg"),
                            ),
                          ),
                        ));
                  },
                ),
                Container(
                  padding: EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: AutoScrollingText(
                          text: title,
                          style: TextStyle(
                            fontSize: 24,
                            color: (themeIndex == 1
                                ? Theme.of(context).colorScheme.onBackground
                                : (theme?.colorScheme.onBackground ??
                                Colors.white)).withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: AutoScrollingText(
                          text: artist,
                          style: TextStyle(
                            fontSize: 18,
                            color: (themeIndex == 1
                                ? Theme.of(context).colorScheme.onBackground
                                : (theme?.colorScheme.onBackground ??
                                Colors.white)).withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: Row(
                          children: [
                            Text((position ~/ 60).toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: (themeIndex == 1
                                      ? Theme.of(context).colorScheme.onBackground
                                      : (theme?.colorScheme.onBackground ??
                                      Colors.white)).withOpacity(0.6),
                                  fontFamily: "monospace",
                                )),
                            Text(":",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: (themeIndex == 1
                                      ? Theme.of(context).colorScheme.onBackground
                                      : (theme?.colorScheme.onBackground ??
                                      Colors.white)).withOpacity(0.6),
                                )),
                            Text(
                              (position % 60)
                                  .toInt()
                                  .toString()
                                  .padLeft(2, "0"),
                              style: TextStyle(
                                fontSize: 18,
                                color: (themeIndex == 1
                                    ? Theme.of(context).colorScheme.onBackground
                                    : (theme?.colorScheme.onBackground ??
                                    Colors.white)).withOpacity(0.6),
                                fontFamily: "monospace",
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: position,
                                min: 0,
                                max: duration + 1,
                                activeColor: (themeIndex == 1
                                        ? Theme.of(context).colorScheme.primary
                                        : (theme?.colorScheme.primary ??
                                            Colors.white))
                                    .withOpacity(0.4),
                                inactiveColor: (themeIndex == 1
                                    ? Theme.of(context).colorScheme.onBackground
                                    : (theme?.colorScheme.onBackground ??
                                    Colors.white)).withOpacity(0.4),
                                thumbColor:
                                themeIndex == 1
                                    ? Theme.of(context).colorScheme.primary
                                    : (theme?.colorScheme.primary ??
                                    Colors.white),
                                label: position.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    Global.player
                                        .seek(Duration(seconds: value.toInt()));
                                    position = value;
                                  });
                                },
                              ),
                            ),
                            Text((duration ~/ 60).toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: (themeIndex == 1
                                      ? Theme.of(context).colorScheme.onBackground
                                      : (theme?.colorScheme.onBackground ??
                                      Colors.white)).withOpacity(0.6),
                                  fontFamily: "monospace",
                                )),
                            Text(":",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: (themeIndex == 1
                                      ? Theme.of(context).colorScheme.onBackground
                                      : (theme?.colorScheme.onBackground ??
                                      Colors.white)).withOpacity(0.6),
                                )),
                            Text(
                              (duration % 60)
                                  .toInt()
                                  .toString()
                                  .padLeft(2, "0"),
                              style: TextStyle(
                                fontSize: 18,
                                color: (themeIndex == 1
                                    ? Theme.of(context).colorScheme.onBackground
                                    : (theme?.colorScheme.onBackground ??
                                    Colors.white)).withOpacity(0.6),
                                fontFamily: "monospace",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Ionicons.play_back,
                            color: (themeIndex == 1
                                ? Theme.of(context).colorScheme.onBackground
                                : (theme?.colorScheme.onBackground ??
                                Colors.white)).withOpacity(0.6), size: 48),
                        onPressed: () async {
                          await Global.player.previous();
                          refresh();
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Transform.translate(
                          offset: Global.player.player.playing
                              ? const Offset(0, 0)
                              : const Offset(4, 0),
                          child: Icon(
                            Global.player.player.playing
                                ? Ionicons.pause
                                : Ionicons.play,
                            color: (themeIndex == 1
                                ? Theme.of(context).colorScheme.onBackground
                                : (theme?.colorScheme.onBackground ??
                                Colors.white)).withOpacity(0.6),
                            size: 48,
                          ),
                        ),
                        onPressed: () async {
                          if (Global.player.player.playing) {
                            setScale(0.9);
                            await Global.player.pause();
                          } else {
                            setScale(1);
                            await Global.player.play();
                          }
                          // Global.player.setInfo();
                          refresh();
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Ionicons.play_forward,
                            color: (themeIndex == 1
                                ? Theme.of(context).colorScheme.onBackground
                                : (theme?.colorScheme.onBackground ??
                                Colors.white)).withOpacity(0.6), size: 48),
                        onPressed: () async {
                          await Global.player.next();
                          refresh();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
