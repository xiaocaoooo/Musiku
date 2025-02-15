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

class PlayerPage extends StatefulWidget {
  final String? path;

  const PlayerPage({super.key, this.path});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  String path = "";
  String cover = "";
  String title = "";
  String artist = "";
  String album = "";
  double duration = 0;
  double position = 0;
  double scale = 1;

  // double position = 0;
  Color primaryColor = const Color(0xFF39C5BB);
  PaletteGenerator paletteGenerator =
      PaletteGenerator.fromColors([PaletteColor(const Color(0xFF39C5BB), 1)]);

  // 新增动画控制器
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
    // setState(() {});
    paletteGenerator = (await getPaletteGeneratorFromImage(cover))!;
    primaryColor = paletteGenerator.dominantColor!.color;
    // Global.themeData = ThemeData(
    //   colorScheme: ColorScheme.fromSeed(
    //       seedColor: primaryColor,
    //       brightness: MediaQuery.of(context).platformBrightness),
    //   useMaterial3: true,
    // );
    // print("player114514 ${widget.path}");
    // album = meta?["album"]?? "";
    // text = "${meta["title"]} - ${meta["artist"]}";
    // primaryColor = await getPrimaryColorFromImage(cover);
    // if (primaryColor != null) {
    //   Global.themeData = Global.themeData.copyWith(
    //     colorScheme: Global.themeData.colorScheme.copyWith(
    //       primary: primaryColor,
    //     ),
    //   );
    // } else {
    //   Global.themeData = Global.themeData.copyWith(
    //     colorScheme: Global.themeData.colorScheme.copyWith(
    //       primary: Color(await UserSettings.getPrimaryColor()),
    //     ),
    //   );
    // }
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
    if (auto) {
      Future.delayed(const Duration(seconds: 1), () => refresh(auto: true));
    }
  }

  // 修改 setScale 方法，使用动画实现平滑切换
  Future<void> setScale(double value) async {
    _scaleController.reset();
    _scaleAnimation = Tween<double>(begin: scale, end: value).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut, // 使用缓动曲线使动画更平滑
      ),
    );
    setState(() {
      scale = value;
    });
    // 启动动画
    await _scaleController.forward();
  }

  void _init() {
    path = Global.playlist[Global.playingIndex];
    initData();
    if (widget.path != null) {
      Global.player.player.setFilePath(widget.path!);
      Global.player.player.play();
    }
    refresh(auto: true);
    // 初始化动画控制器
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // 动画持续时间
    );
    // 预先初始化 _scaleAnimation
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
    // 释放动画控制器资源
    _scaleController.dispose();
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
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Builder(
            builder: (BuildContext context) {
              // 获取屏幕高度
              double screenHeight = MediaQuery.of(context).size.height;
              return Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.18),
                  child: Column(
                    children: [
                      // 使用 AnimatedBuilder 来应用动画
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
                                  )),
                            ),
                          );
                        },
                      ),
                      Container(
                          padding: const EdgeInsets.only(top: 48),
                          child: Column(children: [
                            SizedBox(
                              width: 300,
                              child: AutoScrollingText(
                                text: title,
                                style: TextStyle(
                                  fontSize: 28,
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
                          ])),
                      Container(
                          padding: const EdgeInsets.only(top: 48),
                          child: Column(children: [
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
                                          max: duration,
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
                                              position = value;
                                            });
                                          }),
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
                                )),
                          ])),
                      Container(
                          padding: const EdgeInsets.only(top: 48),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Ionicons.play_skip_back,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 48),
                                  onPressed: () {
                                    Global.player.previous();
                                    refresh();
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: Transform.translate(
                                      // 根据 playing 状态决定是否右移 12px
                                      offset: Global.player.player.playing
                                          ? const Offset(0, 0)
                                          : const Offset(4, 0),
                                      child: Icon(
                                          Global.player.player.playing
                                              ? Ionicons.pause
                                              : Ionicons.play,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 48)),
                                  onPressed: () {
                                    if (Global.player.player.playing) {
                                      setScale(0.9);
                                      Global.player.player.pause();
                                    } else {
                                      setScale(1);
                                      Global.player.player.play();
                                    }
                                    refresh();
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: Icon(Ionicons.play_skip_forward,
                                      color: Colors.white.withOpacity(0.6),
                                      size: 48),
                                  onPressed: () {
                                    Global.player.next();
                                    refresh();
                                    setState(() {});
                                  },
                                )
                              ]))
                    ],
                  ));
            },
          ),
        )
      ]),
    );
  }
}
