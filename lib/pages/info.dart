import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
      List<List<dynamic>> _items=[
        ["QQ", Icon(
          const IconData(0x33, fontFamily: 'iconfont'),
          size: 50,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ), () async {
          String groupNumber = '123456789'; // 替换为你的群号
          String url = 'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=${groupNumber}&card_type=group&source=qrcode';

          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw '无法打开 QQ 群聊';
          }
        }],
      ];
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: SafeArea(
        child: Container(),
      ),
    );
  }
}
