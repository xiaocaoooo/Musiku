import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../const.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  Future<String> getGroupNumber() async {
    final response =
        await http.get(Uri.parse('https://xiaocaoooo.github.io/musiku/qq'));
    if (response.statusCode == 200) {
      return response.body.replaceAll("\n", "");
    } else {
      throw Exception('Failed to load group number');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> items = [
      [
        "QQ",
        Icons.chat_rounded,
        () async {
          try {
            String groupNumber = await getGroupNumber();
            String url =
                'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=$groupNumber&card_type=group&source=qrcode';
            // String url = "https://xiaocaoooo.github.io";
            // print(url);
            if (!await launchUrl(Uri.parse(url))) {
              // 提示用户安装 QQ 应用
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('无法打开链接'),
                    content: const Text('请确保你已经安装了QQ应用。'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            }
          } catch (e) {
            // print('Error: $e');
          }
        }
      ],
      [
        "Github",
        Icons.star,
        () async {
          try {
            String url = "https://github.com/xiaocaoooo/Musiku";
            // print(url);
            if (!await launchUrl(Uri.parse(url))) {
              // 提示用户安装 QQ 应用
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('无法打开链接'),
                    content: const Text('请确保你已经安装了浏览器。'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            }
          } catch (e) {
            // print('Error: $e');
          }
        }
      ],
    ];

    return Scaffold(
      appBar: AppBar(
          title: Text(
        Const.about,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      )),
      body: SafeArea(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Icon(
                items[index][1],
                size: 30,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              title: Text(
                items[index][0],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              trailing: Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
              onTap: items[index][2],
            );
          },
        ),
      ),
    );
  }
}
