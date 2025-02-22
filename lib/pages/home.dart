import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import '../utool.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> announcements = [];

  String imagePath = '';
  String imageCopyright = '';
  String imageTitle = '';
  // PaletteGenerator? paletteGenerator;
  ThemeData? imageTheme;

  @override
  void initState() {
    super.initState();
    fetchAnnouncement();
    fetchBingImage();
    // fetchColor();
  }

  // 发起网络请求获取公告信息
  Future<void> fetchAnnouncement() async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/announcement.json';
    File file = File(filePath);
    if (await file.exists()) {
      // 文件存在，读取本地文件
      String content = await file.readAsString();
      final jsonData = json.decode(content);
      final dataList = jsonData['data'] as List<dynamic>;
      setState(() {
        announcements = dataList.map((item) {
          return {
            'date': item['date'].toString(),
            'content': item['content'].toString(),
            'author': item['author'].toString(),
          };
        }).toList();
      });
    }
    try {
      final response = await http.get(Uri.parse(
          'https://xiaocaoooo.github.io/musiku/announcement.json'));
      if (response.statusCode == 200) {
        // 保存响应内容到本地文件
        file.writeAsString(response.body);
        final jsonData = json.decode(response.body);
        final dataList = jsonData['data'] as List<dynamic>;
        setState(() {
          announcements = dataList.map((item) {
            return {
              'date': item['date'].toString(),
              'content': item['content'].toString(),
              'author': item['author'].toString(),
            };
          }).toList();
        });
      } else {
        // print('请求失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      // print('请求出错: $e');
    }
  }

  // 发起网络请求获取 Bing 图片信息
  Future<void> fetchBingImage() async {
    final info = await getBingImageInfo();
    imagePath = (await getBingImage())!;
    imageCopyright = info["images"][0]["copyright"];
    imageTitle = info["images"][0]["title"];
    setState(() {});
    fetchColor();
    setState(() {});
  }

  Future<void> fetchColor() async {
    Directory tempDir = await getTemporaryDirectory();
    await Directory('${tempDir.path}/bing').create(recursive: true);
    String tempColorPath =
        '${tempDir.path}/bing/${formatDate(DateTime.now())}.color';
    File file = File(tempColorPath);
    if (await file.exists()) {
      // 文件存在，读取本地文件
      String content = await file.readAsString();
      int color = int.parse(content);
      setState(() {
        // paletteGenerator = pg;
        imageTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(color),
            brightness: Theme.of(context).brightness,
          ),
          useMaterial3: true,
        );
      });
      return;
    }
    try {
      final pg = await getPaletteGeneratorFromImage(imagePath);
      if (pg != null) {
        file.writeAsString(pg.dominantColor!.color.value.toString());
        setState(() {
          // paletteGenerator = pg;
          imageTheme = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: pg.dominantColor!.color,
              brightness: Theme.of(context).brightness,
            ),
            useMaterial3: true,
          );
        });
      }
    } catch (e) {
      // print('请求出错: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // fetchColor();
    return Scaffold(
        // appBar: AppBar(title: const Text("Home")),
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              // 使用 ClipRRect 包裹 Container 实现超出部分隐藏
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                clipBehavior: Clip.hardEdge,
                child: Container(
                    width: double.infinity,
                    height: null,
                    decoration: BoxDecoration(
                      color: imageTheme != null
                          ? imageTheme!.colorScheme.primaryContainer
                          : Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 显示图片
                          Image.file(
                            File(imagePath),
                            // "https://bing.img.run/m_302.php",
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 显示图片标题
                                  Text(
                                    imageTitle,
                                    style: TextStyle(
                                        color: imageTheme != null
                                            ? imageTheme!.colorScheme.onPrimaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
                                  ),
                                  // 显示图片版权信息
                                  Text(
                                    imageCopyright,
                                    style: TextStyle(
                                        color: (imageTheme != null
                                            ? imageTheme!.colorScheme.onPrimaryContainer
                                            : Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer)
                                            .withOpacity(0.6),
                                        fontSize: 10.0),
                                  )
                                ]),
                          ),
                        ])),
              )),
          // 新增的外层 Column，用于包裹多个公告容器
          Column(
            children: announcements.map((announcement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  // 宽度设为无限大，实现全宽效果
                  width: double.infinity,
                  // 高度设为null，实现自适应高度
                  height: null,
                  // 使用BoxDecoration来设置容器的样式
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    // 设置圆角半径
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // 这里设置为左对齐
                          children: [
                            Row(
                              children: [
                                Text(
                                  announcement['date']!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withOpacity(0.6),
                                      fontSize: 10.0),
                                ),
                                Text(
                                  " by ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withOpacity(0.6),
                                      fontSize: 10.0),
                                ),
                                Text(
                                  announcement['author']!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withOpacity(0.6),
                                      fontSize: 10.0),
                                )
                              ],
                            ),
                            Text(
                              announcement['content']!,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                            ),
                          ])),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    )));
  }
}
