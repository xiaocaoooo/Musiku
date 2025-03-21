import 'package:flutter/material.dart';
import 'package:musiku/const.dart';
import 'package:musiku/usersettings.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? _selectedLanguage;
  int? _selectedTheme;
  static List<String> _theme=[
    "封面取色",
    "跟随系统",
    "封面模糊"
  ];
  // int? _primaryColor;
  // String? _primaryColorStr;

  // 异步方法用于初始化语言选择
  Future<void> _init() async {
    _selectedLanguage = await UserSettings.getLanguage();
    _selectedTheme = await UserSettings.getTheme();
    // _primaryColor = await UserSettings.getPrimaryColor();
    // _primaryColorStr = '#${_primaryColor?.toRadixString(16).padLeft(8, '0')}';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  // Future<void> _showColorInputDialog() async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: true, // 用户点击对话框外部时是否关闭对话框
  //     builder: (BuildContext context) {
  //       TextEditingController controller =
  //           TextEditingController(text: _primaryColorStr);
  //       return AlertDialog(
  //         title: const Text('请输入文本'),
  //         content: TextField(
  //           controller: controller,
  //           decoration: const InputDecoration(hintText: "#"),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('取消'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('确定'),
  //             onPressed: () {
  //               String inputValue = controller.text;
  //               // 校验输入值是否为合法的 #RRGGBB 格式
  //               if (inputValue.startsWith('#') && inputValue.length == 9) {
  //                 String hexPart = inputValue.substring(1);
  //                 if (RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(hexPart)) {
  //                   setState(() {
  //                     _primaryColorStr = inputValue;
  //                     // 去掉 # 符号
  //                     String hexColor = _primaryColorStr!.replaceFirst('#', '');
  //                     // 将十六进制字符串转换为整数
  //                     int primaryColor = int.parse(hexColor, radix: 16);
  //                     // 保存颜色值
  //                     UserSettings.setPrimaryColor(Color(primaryColor));
  //                   });
  //                   Navigator.of(context).pop();
  //                 } else {
  //                   // 显示错误提示
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text('输入的颜色值格式不正确，请输入 #AARRGGBB 格式的颜色值'),
  //                     ),
  //                   );
  //                 }
  //               } else {
  //                 // 显示错误提示
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('输入的颜色值格式不正确，请输入 #AARRGGBB 格式的颜色值'),
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> _settings = [
      [Const.language, Icons.language, DropdownMenu<String>(
        initialSelection: _selectedLanguage,
        onSelected: (String? value) {
          setState(() {
            UserSettings.setLanguage(value!);
            Const.initialized = false;
            Const.init();
          });
        },
        dropdownMenuEntries: Const.languages
            .map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(
            value: value,
            label: value,
          );
        }).toList(),
      )],
      [Const.foldersSettings, Icons.folder_copy, ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/settings/folders');
          },
          child: Text(
            Const.settings,
          ))],
      [Const.theme, Icons.color_lens, DropdownMenu<String>(
        initialSelection: _theme[_selectedTheme!],
        onSelected: (String? value) {
          setState(() {
            UserSettings.setTheme(_theme.indexOf(value!));
          });
        },
        dropdownMenuEntries: _theme
            .map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(
            value: value,
            label: value,
          );
        }).toList(),
      )],
    ];
    return Scaffold(
      appBar: AppBar(
          title: Text(
        Const.settings,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      )),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _settings.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 12.0, bottom: 12.0),
              child: SizedBox(
                height: 64,
                child: ListTile(
                  title: Text(
                    _settings[index][0],
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                  leading: Icon(
                    _settings[index][1],
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  trailing: _settings[index][2],
                )
              )
            );
          }
        )
      )
    );
    // return Scaffold(
    //   appBar: AppBar(
    //       title: Text(
    //     Const.settings,
    //     style: TextStyle(
    //         color: Theme.of(context).colorScheme.onSecondaryContainer),
    //   )),
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //         SizedBox(
    //             width: double.infinity,
    //             height: null,
    //             child: Padding(
    //               padding: const EdgeInsets.only(
    //                   top: 12.0, bottom: 12.0, left: 24.0, right: 24.0),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   SizedBox(
    //                     child: Row(
    //                       children: [
    //                         Padding(
    //                           padding: const EdgeInsets.only(right: 8.0),
    //                           child: Icon(
    //                             Icons.language,
    //                             color: Theme.of(context)
    //                                 .colorScheme
    //                                 .onSecondaryContainer,
    //                           ),
    //                         ),
    //                         Text(
    //                           Const.language,
    //                           style: TextStyle(
    //                               color: Theme.of(context)
    //                                   .colorScheme
    //                                   .onSecondaryContainer),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   SizedBox(
    //                       child: DropdownMenu<String>(
    //                     initialSelection: _selectedLanguage,
    //                     onSelected: (String? value) {
    //                       setState(() {
    //                         UserSettings.setLanguage(value!);
    //                         Const.initialized = false;
    //                         Const.init();
    //                       });
    //                     },
    //                     dropdownMenuEntries: Const.languages
    //                         .map<DropdownMenuEntry<String>>((String value) {
    //                       return DropdownMenuEntry<String>(
    //                         value: value,
    //                         label: value,
    //                       );
    //                     }).toList(),
    //                   ))
    //                 ],
    //               ),
    //             )),
    //         SizedBox(
    //           width: double.infinity,
    //           height: null,
    //           child: Padding(
    //             padding: const EdgeInsets.only(
    //                 top: 12.0, bottom: 12.0, left: 24.0, right: 24.0),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 SizedBox(
    //                   child: Row(
    //                     children: [
    //                       Padding(
    //                         padding: const EdgeInsets.only(right: 8.0),
    //                         child: Icon(
    //                           Icons.folder_copy,
    //                           color: Theme.of(context)
    //                               .colorScheme
    //                               .onSecondaryContainer,
    //                         ),
    //                       ),
    //                       Text(
    //                         Const.foldersSettings,
    //                         style: TextStyle(
    //                             color: Theme.of(context)
    //                                 .colorScheme
    //                                 .onSecondaryContainer),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 SizedBox(
    //                     child: ElevatedButton(
    //                         onPressed: () {
    //                           Navigator.pushNamed(context, '/settings/folders');
    //                         },
    //                         child: Text(
    //                           Const.settings,
    //                         )))
    //               ],
    //             ),
    //           ),
    //         ),
    //         // SizedBox(
    //         //     width: double.infinity,
    //         //     height: null,
    //         //     child: Padding(
    //         //       padding: const EdgeInsets.only(
    //         //           top: 12.0, bottom: 12.0, left: 24.0, right: 24.0),
    //         //       child: Row(
    //         //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         //         children: [
    //         //           SizedBox(
    //         //             child: Row(
    //         //               children: [
    //         //                 Padding(
    //         //                   padding: const EdgeInsets.only(right: 8.0),
    //         //                   child: Icon(
    //         //                     Icons.color_lens,
    //         //                     color: Theme.of(context)
    //         //                         .colorScheme
    //         //                         .onSecondaryContainer,
    //         //                   ),
    //         //                 ),
    //         //                 Text(
    //         //                   Const.primaryColor,
    //         //                   style: TextStyle(
    //         //                       color: Theme.of(context)
    //         //                           .colorScheme
    //         //                           .onSecondaryContainer),
    //         //                 ),
    //         //               ],
    //         //             ),
    //         //           ),
    //         //           SizedBox(
    //         //               child: TextButton(
    //         //             onPressed: _showColorInputDialog,
    //         //             child: Text(_primaryColorStr!,
    //         //                 style: TextStyle(color: Color(_primaryColor!))),
    //         //           ))
    //         //         ],
    //         //       ),
    //         //     )),
    //       ],
    //     ),
    //   ),
    // );
  }
}
