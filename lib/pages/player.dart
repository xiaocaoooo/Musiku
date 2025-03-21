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

class PlayerPage extends StatefulWidget {
  final String? path;

  const PlayerPage({super.key, this.path});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  String path = "";
  String cover = "";
  String title = "";
  String artist = "";
  String album = "";
  double duration = 0;
  double position = 0;
  double scale = 1;

  Color primaryColor = const Color(0xFF39C5BB);
  PaletteGenerator paletteGenerator =
      PaletteGenerator.fromColors([PaletteColor(const Color(0xFF39C5BB), 1)]);

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // 新增下滑动画控制器
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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
    if (widget.path != null) {
      Global.player.setFilePath(widget.path!);
      Global.player.play();
    }
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

    // 初始化下滑动画控制器
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    _slideController.value +=
        details.primaryDelta! / MediaQuery.of(context).size.height;
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // 设定一个速度阈值，可根据实际情况调整
    const double velocityThreshold = 1000;
    if (details.velocity.pixelsPerSecond.dy > velocityThreshold) {
      // 下滑速度超过阈值，关闭页面
      _slideController
          .animateTo(1.0, duration: const Duration(milliseconds: 200))
          .then((_) {
        Navigator.of(context).pop();
      });
    } else {
      // 下滑速度未超过阈值，恢复原位
      _slideController.animateTo(0.0,
          duration: const Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Scaffold(
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
          SlideTransition(
            position: _slideAnimation,
            child: SizedBox(
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
                              child: InkWell(
                                  onTap: () async {
                                    Navigator.pushNamed(context, "/lyric");
                                  },
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
                                                width: 300,
                                                height: 300,
                                              )
                                            : Image.asset(
                                                "assets/images/default_player_cover.jpg"),
                                      ),
                                    ),
                                  )),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 48),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 300,
                                child: AutoScrollingText(
                                  text: title,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white.withOpacity(0.8),
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
                                    color: Colors.white.withOpacity(0.6),
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
                                          color: Colors.white.withOpacity(0.6),
                                          fontFamily: "monospace",
                                        )),
                                    Text(":",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.6),
                                        )),
                                    Text(
                                      (position % 60)
                                          .toInt()
                                          .toString()
                                          .padLeft(2, "0"),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white.withOpacity(0.6),
                                        fontFamily: "monospace",
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: position,
                                        min: 0,
                                        max: duration + 1,
                                        activeColor: paletteGenerator
                                                    .lightVibrantColor !=
                                                null
                                            ? paletteGenerator
                                                .lightVibrantColor?.color
                                                .withOpacity(0.4)
                                            : Colors.white.withOpacity(0.4),
                                        inactiveColor:
                                            Colors.white.withOpacity(0.4),
                                        thumbColor: paletteGenerator
                                                    .lightVibrantColor !=
                                                null
                                            ? paletteGenerator
                                                .lightVibrantColor!.color
                                            : Colors.white,
                                        label: position.toString(),
                                        onChanged: (value) {
                                          setState(() {
                                            Global.player.seek(Duration(
                                                seconds: value.toInt()));
                                            position = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Text((duration ~/ 60).toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.6),
                                          fontFamily: "monospace",
                                        )),
                                    Text(":",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.6),
                                        )),
                                    Text(
                                      (duration % 60)
                                          .toInt()
                                          .toString()
                                          .padLeft(2, "0"),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white.withOpacity(0.6),
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
                                    color: Colors.white.withOpacity(0.6),
                                    size: 48),
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
                                    color: Colors.white.withOpacity(0.6),
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
                                    color: Colors.white.withOpacity(0.6),
                                    size: 48),
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
            ),
          ),
        ]),
      ),
    );
  }
}
