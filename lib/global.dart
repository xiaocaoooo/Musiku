import 'package:musiku/player.dart';

class Global {
  static Player player = Player();
  // static FlutterRadioPlayer player = FlutterRadioPlayer();
  // static ThemeData themeData = ThemeData();
  //   colorScheme: ColorScheme.fromSeed(
  //       seedColor: primaryColor,
  //       brightness: MediaQuery.of(context).platformBrightness),
  //   useMaterial3: true,
  // );
  static Map<String, dynamic> musicInfo = {};
  static Map<String, int> musicLastModified = {};
  static List<String> playlist = [];
  static int playingIndex = -1;
  static Map<String, String> coverCache = {};
}