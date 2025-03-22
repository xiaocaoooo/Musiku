import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:musiku/global.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getMusicMetadata(String filePath,
    {bool cache = true, int retry = 5}) async {
  if (retry <= 0) {
    return null;
  }
  Directory tempDir = await getTemporaryDirectory();
  await Directory('${tempDir.path}/meta').create(recursive: true);
  String tempFilePath = '${tempDir.path}/meta/${filePath.split("/").last}.json';
  Map<String, dynamic> meta = {};

  if (cache) {
    // if (Global.musicInfo[filePath] == null) {
    // Map<String, dynamic>? metadata =
    //     await UserSettings.getMusicInfo(filePath);
    // if (metadata != null) {
    //   Global.musicInfo[filePath] = metadata;
    //   return metadata;
    // }
    if (File(tempFilePath).existsSync()) {
      final jsonFile = File(tempFilePath);
      final jsonString = await jsonFile.readAsString();
      final metadata = json.decode(jsonString);
      // getCover(filePath);
      // print("metadata : $metadata");
      Global.musicInfo[metadata["filePath"]] = metadata;
      return metadata;
    }
    final metadata =
        await getMusicMetadata(filePath, cache: false, retry: retry);
    // if (metadata != null) {
    //   Global.musicInfo[filePath] = metadata;
    //   // UserSettings.setMusicInfo(filePath, metadata);
    // }
    return metadata;
    // }
    // return Global.musicInfo[filePath];
  }
  File file;
  FlutterFFprobe flutterFFprobe;
  MediaInformation info;
  Map<dynamic, dynamic>? mediaProperties;
  try {
    file = File(filePath);
    flutterFFprobe = FlutterFFprobe();
    info = await flutterFFprobe.getMediaInformation(filePath);
    mediaProperties = info.getMediaProperties();
  } catch (e) {
    await Future.delayed(const Duration(seconds: 1));
    return await getMusicMetadata(filePath, retry: retry - 1);
  }
  // meta = {
  //   "title": mediaProperties?["tags"]["title"]??mediaProperties?["tags"]["TITLE"],
  //   "artist": mediaProperties?["tags"]["artist"]??mediaProperties?["tags"]["ARTIST"],
  //   "album": mediaProperties?["tags"]["album"]??mediaProperties?["tags"]["ALBUM"],
  //   "duration": mediaProperties?["duration"],
  //   "filePath": filePath,
  //   "lastModified": file.lastModifiedSync().millisecondsSinceEpoch,
  //   "lyrics": mediaProperties?["tags"]["lyrics"] ??
  //       mediaProperties?["tags"]["lyrics-eng"] ??
  //       mediaProperties?["tags"]["LYRICS"]??
  //       "",
  // };
  if (filePath.endsWith('.mp3')) {
    if (mediaProperties?["tags"]["title"] == null) {
      await Future.delayed(const Duration(seconds: 1));
      return await getMusicMetadata(filePath, retry: retry - 1);
    }
    meta = {
      "title": mediaProperties?["tags"]["title"],
      "artist": mediaProperties?["tags"]["artist"],
      "album": mediaProperties?["tags"]["album"],
      "duration": double.parse(mediaProperties?["duration"] ?? "0.0").toInt(),
      "filePath": mediaProperties?["filename"],
      "lastModified": file.lastModifiedSync().millisecondsSinceEpoch,
      // "lyrics": lyric
      //     ? (mediaProperties?["tags"]["lyrics"] ??
      //         mediaProperties?["tags"]["lyrics-eng"] ??
      //         "")
      //     : "",
    };
    Global.musicInfo[mediaProperties?["filename"]] = meta;
    final jsonFile = File(tempFilePath);
    await jsonFile.writeAsString(json.encode(meta));
    return meta;
  } else if (filePath.endsWith('.flac')) {
    if (mediaProperties?["tags"]["TITLE"] == null) {
      await Future.delayed(const Duration(seconds: 1));
      return await getMusicMetadata(filePath, retry: retry - 1);
    }
    meta = {
      "title": mediaProperties?["tags"]["TITLE"],
      "artist": mediaProperties?["tags"]["ARTIST"],
      "album": mediaProperties?["tags"]["ALBUM"],
      "duration": double.parse(mediaProperties?["duration"] ?? "0.0").toInt(),
      "filePath": mediaProperties?["filename"],
      "lastModified": file.lastModifiedSync().millisecondsSinceEpoch,
      // "lyrics": lyric ? (mediaProperties?["tags"]["LYRICS"] ?? "") : "",
    };
    Global.musicInfo[mediaProperties?["filename"]] = meta;
    final jsonFile = File(tempFilePath);
    await jsonFile.writeAsString(json.encode(meta));
    return meta;
  }
  return null;
}

String processDuration(int duration) {
  final minutes = duration ~/ 60;
  final remainingSeconds = duration % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

Future<String> getLyrics(String filePath, {int retry = 5}) async {
  if (retry <= 0) {
    return "";
  }
  final FlutterFFprobe flutterFFprobe = FlutterFFprobe();
  final info = await flutterFFprobe.getMediaInformation(filePath);
  final mediaProperties = info.getMediaProperties();
  if (filePath.endsWith('.mp3')) {
    if (mediaProperties?["tags"]["title"] == null) {
      await Future.delayed(const Duration(seconds: 1));
      return await getLyrics(filePath, retry: retry - 1);
    }
    return mediaProperties?["tags"]["lyrics"] ??
        mediaProperties?["tags"]["lyrics-eng"] ??
        "";
  } else if (filePath.endsWith('.flac')) {
    if (mediaProperties?["tags"]["TITLE"] == null) {
      await Future.delayed(const Duration(seconds: 1));
      return await getLyrics(filePath, retry: retry - 1);
    }
    return mediaProperties?["tags"]["LYRICS"] ?? "";
  }
  return "";
}

Future<String?> getCover(String filePath, {cache = true}) async {
  Directory tempDir = await getTemporaryDirectory();
  await Directory('${tempDir.path}/covers').create(recursive: true);
  String tempFilePath =
      '${tempDir.path}/covers/${filePath.split("/").last}.jpg';
  if (cache) {
    if (await File(tempFilePath).exists()) {
      Global.coverCache[filePath] = tempFilePath;
      return tempFilePath;
    }
  }
  final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
  try {
    await flutterFFmpeg
        .execute('-i $filePath -y -an -vcodec copy $tempFilePath');
  } catch (e) {
    // print(e);
  }
  if (await File(tempFilePath).exists()) {
    Global.coverCache[filePath] = tempFilePath;
    return tempFilePath;
  }
  return null;
}

Future<Color?> getPrimaryColorFromImage(String filePath) async {
  try {
    // print("getPrimaryColorFromImage: ${filePath}");
    // 根据文件路径创建一个本地图片提供者
    final imageProvider = FileImage(File(filePath));
    // 从图片提供者生成调色板
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
    );
    // 获取主色调，如果主色调为空则返回白色
    // print("getPrimaryColorFromImage: ${paletteGenerator.dominantColor?.color}");
    return paletteGenerator.dominantColor?.color;
  } catch (e) {
    // 若出现异常，打印错误信息并返回白色
    // print('Error getting primary color: $e');
    return null;
  }
}

Future<PaletteGenerator?> getPaletteGeneratorFromImage(String filePath) async {
  try {
    // print("getPrimaryColorFromImage: ${filePath}");
    // 根据文件路径创建一个本地图片提供者
    final imageProvider = FileImage(File(filePath));
    // 从图片提供者生成调色板
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
    );
    return paletteGenerator;
  } catch (e) {
    // 若出现异常，打印错误信息并返回白色
    // print('Error getting primary color: $e');
    return null;
  }
}

Future<PaletteGenerator?> getPaletteGeneratorFromImageURL(String url) async {
  try {
    // print("getPrimaryColorFromImage: $url");
    // 根据文件路径创建一个本地图片提供者
    final imageProvider = NetworkImage(url);
    // 从图片提供者生成调色板
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
    );
    return paletteGenerator;
  } catch (e) {
    // 若出现异常，打印错误信息并返回白色
    // print('Error getting primary color: $e');
    return null;
  }
}

Future<dynamic> getBingImageInfo() async {
  Directory tempDir = await getTemporaryDirectory();
  await Directory('${tempDir.path}/bing').create(recursive: true);
  String tempJsonPath =
      '${tempDir.path}/bing/${formatDate(DateTime.now())}.json';
  if (!File(tempJsonPath).existsSync()) {
    final response = await http.get(Uri.parse(
        'https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN'));
    if (response.statusCode == 200) {
      final jsonFile = File(tempJsonPath);
      await jsonFile.writeAsString(response.body);
      // print("getBingImageInfo: ${json.decode(response.body)}");
      return json.decode(response.body);
    }
  } else {
    final jsonFile = File(tempJsonPath);
    final jsonString = await jsonFile.readAsString();
    // print("getBingImageInfo: ${json.decode(jsonString)}");
    return json.decode(jsonString);
  }
}

Future<String?> getBingImage() async {
  Directory tempDir = await getTemporaryDirectory();
  await Directory('${tempDir.path}/bing').create(recursive: true);
  String tempImgPath = '${tempDir.path}/bing/${formatDate(DateTime.now())}.jpg';
  late dynamic jsonData;
  try {
    jsonData = await getBingImageInfo();
    // print("getBingImage123${jsonData}");
    // print("getBingImage: ${jsonData['images'][0]['url']}");
    if (!File(tempImgPath).existsSync()) {
      await downloadFile(
          'https://cn.bing.com${jsonData['images'][0]['url']}', tempImgPath);
      return tempImgPath;
    } else {
      return tempImgPath;
    }
  } catch (e) {
    return null;
  }
}

String formatDate(DateTime date) {
  String year = date.year.toString();
  // 确保月份是两位数
  String month = date.month.toString().padLeft(2, '0');
  // 确保日期是两位数
  String day = date.day.toString().padLeft(2, '0');
  return '$year$month$day';
}

Future<void> downloadFile(String url, String savePath) async {
  final response = await http.get(Uri.parse(url));
  final file = File(savePath);
  await file.writeAsBytes(response.bodyBytes);
}

double abs(double num) {
  return num < 0 ? -num : num;
}

// Future<Map<String, dynamic>?> getMusicMetadata(String filePath) async {
//   if (filePath.endsWith('.mp3')) {
//     return getMp3Metadata(filePath);
//   } else if (filePath.endsWith('.flac')) {
//     // return getFlacMetadata(filePath);
//   }
//   return null;
// }
//
// Future<Map<String, dynamic>?> getMp3Metadata(String filePath,
//     {bool cache = true}) async {
//   Map<String, dynamic> meta = {};
//   if (cache) {
//     if (!Global.musicInfo.containsKey(filePath)) {
//       Map<String, dynamic>? metadata =
//       await UserSettings.getMusicInfo(filePath);
//       if (metadata != null) {
//         Global.musicInfo[filePath] = metadata;
//         return metadata;
//       }
//       metadata = await getMp3Metadata(filePath, cache: false);
//       if (metadata != null) {
//         Global.musicInfo[filePath] = metadata;
//         UserSettings.setMusicInfo(filePath, metadata);
//       }
//       return metadata;
//     }
//   }
//   final file = File(filePath);
//   final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();
//   final info = await _flutterFFprobe.getMediaInformation(filePath);
//   final mediaProperties = info.getMediaProperties();
//   meta = {
//     "title": mediaProperties?["tags"]["title"],
//     "artist": mediaProperties?["tags"]["artist"],
//     "album": mediaProperties?["tags"]["album"],
//     "duration": mediaProperties?["duration"],
//     "filePath": filePath,
//     "lastModified": file.lastModifiedSync().millisecondsSinceEpoch,
//     "lyrics": mediaProperties?["tags"]["lyrics"] ??
//         mediaProperties?["tags"]["lyrics-eng"] ??
//         "",
//   };
//   return meta;
// }
