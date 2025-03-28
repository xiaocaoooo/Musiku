import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:musiku/pages/index.dart';
import 'package:musiku/pages/lyric.dart';
import 'package:musiku/utool.dart';
import 'package:permission_handler/permission_handler.dart'; // 导入权限处理包
import 'package:musiku/const.dart';
import 'package:musiku/global.dart';
import 'package:musiku/pages/debug.dart';
import 'package:musiku/pages/folders_settings.dart';
import 'package:musiku/pages/home.dart';
import 'package:musiku/pages/info.dart';
import 'package:musiku/pages/more.dart';
import 'package:musiku/pages/music.dart';
import 'package:musiku/pages/music_list.dart';
import 'package:musiku/pages/player.dart';
import 'package:musiku/pages/playlist.dart';
import 'package:musiku/pages/search.dart';
import 'package:musiku/pages/settings.dart';
import 'package:musiku/pages/text_page.dart';
import 'package:musiku/usersettings.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'auto_scrolling_text.dart';
import 'background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化用户设置
  await UserSettings.initSettings();
  await Const.init();

  // 检查并请求 READ_MEDIA_AUDIO 权限
  checkAndRequestAudioPermission();

  Global.isolate =
      await Isolate.spawn(backgroundTask, Global.receivePort.sendPort);

  runApp(const MyApp());
}

// 检查并请求 READ_MEDIA_AUDIO 权限的函数
Future<void> checkAndRequestAudioPermission() async {
  PermissionStatus status = await Permission.audio.request();
  if (status.isDenied) {
    // 如果权限被拒绝，显示一个提示框
    checkAndRequestAudioPermission();
    // print('音频权限被拒绝');
  } else if (status.isPermanentlyDenied) {
    // 如果权限被永久拒绝，引导用户去设置中开启权限
    openAppSettings();
    // print('音频权限被永久拒绝，请在设置中开启权限');
  } else if (status.isGranted) {
    // 权限已授予
    // print('音频权限已授予');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Future<void> setTheme(BuildContext context) async {
  //   int primaryColorValue = await UserSettings.getPrimaryColor();
  //   Color primaryColor = Color(primaryColorValue);
  //   Global.themeData = ThemeData(
  //     colorScheme: ColorScheme.fromSeed(
  //         seedColor: primaryColor,
  //         brightness: MediaQuery.of(context).platformBrightness),
  //     useMaterial3: true,
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(
    //         // seedColor: Theme.of(context).colorScheme.primary,
    //       seedColor: Color(0xFF39C5BB),
    //         brightness: MediaQuery.of(context).platformBrightness),
    //     useMaterial3: true,
    //   ),
    //   // theme: Global.themeData,
    //   initialRoute: '/',
    //   // home: const BottomNavigationExample(),
    //   routes: {
    //     '/': (context) => const BottomNavigationExample(),
    //     '/home': (context) => const HomePage(),
    //     '/more': (context) => const MorePage(),
    //     "/settings": (context) => const Settings(),
    //     "/info": (context) => const Info(),
    //     "/debug": (context) => const Debug(),
    //     "/settings/folders": (context) => const FoldersSettings(),
    //     "/music": (context) => const MusicPage(),
    //     "/playlist": (context) => const PlaylistPage(),
    //     "/search": (context) => const SearchPage(),
    //     "/music_list": (context) {
    //       // 从路由参数中获取 path 参数
    //       final String path =
    //           ModalRoute.of(context)?.settings.arguments as String;
    //       return MusicListPage(path: path);
    //     },
    //     "/text_page": (context) {
    //       final String text =
    //           ModalRoute.of(context)?.settings.arguments as String;
    //       return TextPage(text: text);
    //     },
    //     "/player": (context) {
    //       final String? path =
    //           ModalRoute.of(context)?.settings.arguments as String?;
    //       return PlayerPage(path: path);
    //     },
    //     // "/player": (context) => const PlayerPage(),
    //     "/lyric": (context) => LyricPage(),
    //   },
    // );
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // print("primary${(Global.darkThemeData??ThemeData(colorScheme: darkDynamic, useMaterial3: true)).colorScheme.primary}");
        return MaterialApp(
          // theme: ThemeData(
          //   colorScheme: ColorScheme.fromSeed(
          //     // seedColor: Theme.of(context).colorScheme.primary,
          //       seedColor: Color(0xFF39C5BB),
          //       brightness: MediaQuery.of(context).platformBrightness),
          //   useMaterial3: true,
          // ),
          theme: ThemeData(colorScheme: lightDynamic, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkDynamic, useMaterial3: true),
          // theme: Global.themeData,
          initialRoute: '/',
          // home: const BottomNavigationExample(),
          routes: {
            '/': (context) => const App(),
            '/home': (context) => const HomePage(),
            '/more': (context) => const MorePage(),
            "/settings": (context) => const Settings(),
            "/info": (context) => const Info(),
            "/debug": (context) => const Debug(),
            "/settings/folders": (context) => const FoldersSettings(),
            "/music": (context) => const MusicPage(),
            "/playlist": (context) => const PlaylistPage(),
            "/search": (context) => const SearchPage(),
            "/music_list": (context) {
              // 从路由参数中获取 path 参数
              final String path =
                  ModalRoute.of(context)?.settings.arguments as String;
              return MusicListPage(path: path);
            },
            "/text_page": (context) {
              final String text =
                  ModalRoute.of(context)?.settings.arguments as String;
              return TextPage(text: text);
            },
            "/player": (context) {
              final String? path =
                  ModalRoute.of(context)?.settings.arguments as String?;
              return PlayerPage(path: path);
            },
            // "/player": (context) => const PlayerPage(),
            "/lyric": (context) => const LyricPage(),
            "/index": (context) => const IndexPage(),
          },
        );
      },
    );
  }

  ThemeData buildTheme(ColorScheme? dynamicScheme, bool isDarkMode) {
    ColorScheme colorScheme = dynamicScheme ??
        (isDarkMode ? const ColorScheme.dark() : const ColorScheme.light());
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return FutureBuilder<int>(
//     future: UserSettings.getPrimaryColor(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         // 异步操作还在进行中，显示加载状态
//         print("Loading...");
//         return Container();
//       } else if (snapshot.hasError) {
//         // 异步操作出错，显示错误信息
//         return Text('Error: ${snapshot.error}');
//       } else {
//         int primaryColorValue = snapshot.data!;
//         Color primaryColor = Color(primaryColorValue);
//         return MaterialApp(
//           theme: ThemeData(
//             colorScheme: ColorScheme.fromSeed(
//                 seedColor: primaryColor,
//                 brightness: MediaQuery.of(context).platformBrightness),
//             useMaterial3: true,
//           ),
//           // theme: Global.themeData,
//           initialRoute: '/',
//           // home: const BottomNavigationExample(),
//           routes: {
//             '/': (context) => const BottomNavigationExample(),
//             '/home': (context) => const HomePage(),
//             '/more': (context) => const MorePage(),
//             "/settings": (context) => const Settings(),
//             "/info": (context) => const Info(),
//             "/debug": (context) => const Debug(),
//             "/settings/folders": (context) => const FoldersSettings(),
//             "/music": (context) => const MusicPage(),
//             "/playlist": (context) => const PlaylistPage(),
//             "/search": (context) => const SearchPage(),
//             "/music_list": (context) {
//               // 从路由参数中获取 path 参数
//               final String path =
//                   ModalRoute.of(context)?.settings.arguments as String;
//               return MusicListPage(path: path);
//             },
//             "/text_page": (context) {
//               final String text =
//                   ModalRoute.of(context)?.settings.arguments as String;
//               return TextPage(text: text);
//             },
//             "/player": (context) {
//               final String? path =
//               ModalRoute.of(context)?.settings.arguments as String?;
//               return PlayerPage(path: path);
//             },
//             // "/player": (context) => const PlayerPage(),
//           },
//         );
//       }
//     },
//   );
// }
// }

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // 当前选中的页面索引
  int _selectedIndex = 0;
  String cover = "";
  ThemeData theme = ThemeData();

  @override
  void initState() {
    super.initState();
    _init();
    refresh(auto: true);
  }

  // 定义不同页面的内容
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const SearchPage(),
    const MusicPage(),
    // const PlaylistPage(),
    const MorePage()
  ];

  final PageController _pageController = PageController(keepPage: true);

  Future<void> _init() async {
    if (Global.playingIndex != -1) {
      cover = (await getCover(Global.playlist[Global.playingIndex]))!;
      theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              (await getPaletteGeneratorFromImage(cover))!.dominantColor!.color,
          brightness: MediaQuery.of(context).platformBrightness,
        ),
        useMaterial3: true,
      );
    }
  }

  Future<void> refresh({bool auto = false}) async {
    await _init();
    // print("cover $cover");
    setState(() {});
    if (auto && mounted) {
      Future.delayed(
          const Duration(milliseconds: 500), () => refresh(auto: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    // WidgetsFlutterBinding.ensureInitialized();
    // // 根据系统主题模式设置底部导航栏颜色
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent, // 去除状态栏遮罩
    //   statusBarIconBrightness: Brightness.dark, // 状态栏图标字体颜色
    //   systemNavigationBarColor: Theme.of(context).colorScheme.surface,
    //   // systemNavigationBarColor:
    //   //     MediaQuery.of(context).platformBrightness == Brightness.light
    //   //         ? Colors.white
    //   //         : Colors.black,
    // ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // 设置状态栏和导航栏背景为透明
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      // 设置状态栏和导航栏图标颜色为白色
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      extendBody: true,
      // 让 body 延伸到 bottomNavigationBar 下方
      // extendBodyBehindAppBar: true, // 让 body 延伸到 AppBar 下方
      appBar: AppBar(
        title: Text(Const.appName,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold)),
        // backgroundColor: Colors.transparent,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      floatingActionButton: Global.playingIndex != -1
          ?
          // FloatingActionButton(
          //   onPressed: () {
          //     Navigator.pushNamed(context, "/player");
          //   },
          //   child: const Icon(Icons.music_note),
          // )
          Builder(builder: (context) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16 + 15),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 100,
                        child: Stack(children: [
                          InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, "/player");
                                _init();
                                setState(() {});
                              },
                              child: Container(
                                color: theme.colorScheme.primaryContainer
                                    .withOpacity(0.5),
                              )),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, top: 15, bottom: 15),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, "/player");
                                    _init();
                                    setState(() {});
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
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
                                                  width: 70,
                                                  height: 70,
                                                )
                                              : Image.asset(
                                                  "assets/images/default_player_cover.jpg"),
                                        ),
                                      ))),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoScrollingText(
                                  text: Global.musicInfo[Global
                                              .playlist[Global.playingIndex]]
                                          ?["title"] ??
                                      Global.playlist[Global.playingIndex]
                                          .split("/")
                                          .last,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // const SizedBox(height: 4),
                                AutoScrollingText(
                                  text: Global.musicInfo[Global
                                              .playlist[Global.playingIndex]]
                                          ?["artist"] ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withOpacity(0.6),
                                  ),
                                ),
                                SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(Ionicons.play_back,
                                              color: theme
                                                  .colorScheme.onPrimaryContainer
                                                  .withOpacity(0.6),
                                              size: 24),
                                          onPressed: () async {
                                            await Global.player.previous();
                                            refresh();
                                            setState(() {});
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Transform.translate(
                                            offset: Global.player.player.playing
                                                ? const Offset(0, 0)
                                                : const Offset(4, 0),
                                            child: Icon(
                                              Global.player.player.playing
                                                  ? Ionicons.pause
                                                  : Ionicons.play,
                                              color: theme
                                                  .colorScheme.onPrimaryContainer
                                                  .withOpacity(0.6),
                                              size: 24,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (Global.player.player.playing) {
                                              await Global.player.pause();
                                            } else {
                                              await Global.player.play();
                                            }
                                            // Global.player.setInfo();
                                            refresh();
                                            setState(() {});
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Ionicons.play_forward,
                                              color: theme
                                                  .colorScheme.onPrimaryContainer
                                                  .withOpacity(0.6),
                                              size: 24),
                                          onPressed: () async {
                                            await Global.player.next();
                                            refresh();
                                            setState(() {});
                                          },
                                        ),
                                        const SizedBox(width: 115,)
                                      ],
                                    ))
                              ],
                            ))
                          ]),
                          // Positioned(
                          //     left:
                          //         (MediaQuery.of(context).size.width - 32) / 2 -
                          //             44,
                          //     bottom: 15,
                          //     child: )
                        ]))),
              );
            })
          : null,
      bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          // backgroundColor: Colors.transparent,
          // elevation: 0,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.5),
          // 当前选中的索引
          selectedIndex: _selectedIndex,
          // 点击事件处理
          onDestinationSelected: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300), // 动画持续时间
              curve: Curves.easeInOut, // 动画曲线
            );
          },
          // 底部导航栏的目的地（即每个导航项）
          destinations: <Widget>[
            NavigationDestination(
              icon: const Icon(Icons.home),
              label: Const.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search),
              label: Const.search,
            ),
            NavigationDestination(
              icon: const Icon(Icons.library_music),
              label: Const.music,
            ),
            // NavigationDestination(
            //   icon: const Icon(Icons.playlist_play),
            //   label: Const.playlist,
            // ),
            NavigationDestination(
              icon: const Icon(Icons.settings),
              label: Const.more,
            ),
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// 新的 HomePage 包装类，用于保持页面状态
// class HomePageWithKeepAlive extends StatefulWidget {
//   const HomePageWithKeepAlive({super.key});
//
//   @override
//   State<HomePageWithKeepAlive> createState() => _HomePageWithKeepAliveState();
// }
//
// class _HomePageWithKeepAliveState extends State<HomePageWithKeepAlive>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return const HomePage();
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
