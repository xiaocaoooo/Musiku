import 'package:flutter/material.dart';
import 'package:musiku/const.dart';
import 'package:musiku/usersettings.dart';
import 'package:musiku/pages/music_list.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<String>? _folders;
  late PageController _pageController;
  int _currentPageIndex = 0;

  Future<void> _init() async {
    _folders = await UserSettings.getFolders();
    _folders = [Const.all, ..._folders!];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Music Page'),
      // ),
      body: Column(
        children: [
          // 标签部分
          _folders == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _folders!.length,
                      (index) {
                        // 将文件夹路径按 / 分割
                        List<String> parts = _folders![index].split('/');
                        // 获取分割后的倒数第二个部分
                        String displayText = parts.length > 1
                            ? parts[parts.length - 2]
                            : parts[0];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentPageIndex = index;
                            });
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _currentPageIndex == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              displayText,
                              style: TextStyle(
                                color: _currentPageIndex == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          // 页面部分
          Expanded(
            child: _folders == null
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _folders!.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return MusicListPage(path: _folders![index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
