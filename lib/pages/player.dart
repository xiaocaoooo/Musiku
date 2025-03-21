import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:musiku/auto_scrolling_text.dart';
import 'package:musiku/global.dart';
import 'package:musiku/pages/lyric.dart';
import 'package:musiku/pages/playing.dart';
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
  ThemeData? theme;
  int themeIndex = 0;

  Color primaryColor = const Color(0xFF39C5BB);
  PaletteGenerator paletteGenerator =
      PaletteGenerator.fromColors([PaletteColor(const Color(0xFF39C5BB), 1)]);

  // 新增下滑动画控制器
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Future<void> initData() async {
    cover = (await getCover(path))!;
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

  void _init() {
    path = Global.playlist[Global.playingIndex];
    initData();
    if (widget.path != null) {
      Global.player.setFilePath(widget.path!);
      Global.player.play();
    }

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
    // widget.path=null;
    Widget background = Expanded(
        child: Container(
      color: theme?.colorScheme.secondaryContainer ?? Theme.of(context).colorScheme.secondaryContainer,
    ));
    if (themeIndex == 1) {
      background = Expanded(
          child: Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
      ));
    } else if (themeIndex == 2) {
      background = Expanded(
          child: Stack(children: [
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
        )
      ]));
    }
    return Scaffold(
        body: GestureDetector(
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            onVerticalDragEnd: _handleVerticalDragEnd,
            child: Stack(children: [
              background,
              SlideTransition(
                  position: _slideAnimation,
                  child: PageView(children: [
                    const Expanded(child: PlayingPage()),
                    Expanded(child: LyricPage())
                  ]))
            ])));
  }
}
