import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:musiku/player.dart';

import 'background.dart';

class Global {
  static bool firstRun = true;
  static Player player = Player();

  // static FlutterRadioPlayer player = FlutterRadioPlayer();
  // static ThemeData themeData = ThemeData();
  //   colorScheme: ColorScheme.fromSeed(
  //       seedColor: primaryColor,
  //       brightness: MediaQuery.of(context).platformBrightness),
  //   useMaterial3: true,
  // );
  // static ThemeData lightThemeData = ThemeData(
  //     colorScheme: ColorScheme.fromSeed(
  //         seedColor: Color(0xff39c5bb), brightness: Brightness.light),
  //     brightness: Brightness.light,
  //     useMaterial3: true);
  // static ThemeData darkThemeData = ThemeData(
  //     colorScheme: ColorScheme.fromSeed(
  //         seedColor: Color(0xff39c5bb), brightness: Brightness.dark),
  //     brightness: Brightness.dark,
  //     useMaterial3: true);
  static ThemeData? lightThemeData;
  static ThemeData? darkThemeData;
  static Map<String, dynamic> musicInfo = {};
  static Map<String, int> musicLastModified = {};
  static List<String> playlist = [];
  static int playingIndex = -1;
  static Map<String, String> coverCache = {};
  static ReceivePort receivePort = ReceivePort();
  static late Isolate isolate;
  static List<dynamic> lrcs = [];
}
