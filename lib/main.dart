import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musiku/pages/index.dart';
import 'package:musiku/pages/lyric.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化用户设置
  await UserSettings.initSettings();
  await Const.init();

  // 检查并请求 READ_MEDIA_AUDIO 权限
  checkAndRequestAudioPermission();

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
              "/lyric": (context) => LyricPage(),
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

  @override
  void initState() {
    super.initState();
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
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/player");
              },
              child: const Icon(Icons.music_note),
            )
          : null,
      bottomNavigationBar: ClipRRect(
        child:BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: NavigationBar(
            // backgroundColor: Colors.transparent,
            // elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
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
        )
      ),
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
