import 'package:flutter/material.dart';
import 'package:musiku/const.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final List<List<String>> _settings = [
    [Const.settings, "/settings"],
    [Const.about, "/info"],
    [Const.index, "/index"]
    // [Const.debug, "/debug"],
  ];
  final List<IconData> _icons = [Icons.settings, Icons.info, Icons.music_note];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("More")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  height: null,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.asset("assets/icon/app_icon.png",
                                  width: 64.0, height: 64.0),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(Const.appName,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: Container()),
                            Text(Const.version,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.6),
                                  fontSize: 14.0,
                                )),
                          ]))),
              Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _settings.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Row(children: [
                            Icon(_icons[index],
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                            const SizedBox(height: 1.0, width: 8.0),
                            Text(_settings[index][0],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer)),
                          ]),
                          trailing: Icon(Icons.chevron_right,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer),
                          onTap: () {
                            Navigator.pushNamed(context, _settings[index][1]);
                          },
                        );
                      })
                  // Column(children: [
                  //   Padding(
                  //       padding: const EdgeInsets.only(bottom: 8.0),
                  //       child: TextButton(
                  //           style: TextButton.styleFrom(
                  //             splashFactory: NoSplash.splashFactory,
                  //
                  //           ),
                  //           onPressed: () {
                  //             Navigator.pushNamed(context, '/settings');
                  //           },
                  //           child: SizedBox(
                  //             child: Row(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   SizedBox(
                  //                     child: Row(children: [
                  //                       Padding(
                  //                         padding:
                  //                             const EdgeInsets.only(right: 8.0),
                  //                         child: Icon(Icons.settings,
                  //                             color: Theme.of(context)
                  //                                 .colorScheme
                  //                                 .onSecondaryContainer),
                  //                       ),
                  //                       Text(
                  //                         Const.settings,
                  //                         style: TextStyle(
                  //                             color: Theme.of(context)
                  //                                 .colorScheme
                  //                                 .onSecondaryContainer),
                  //                       ),
                  //                     ]),
                  //                   ),
                  //                   SizedBox(
                  //                       child: Icon(Icons.chevron_right,
                  //                           color: Theme.of(context)
                  //                               .colorScheme
                  //                               .onSecondaryContainer))
                  //                 ]),
                  //           ))),
                  //   Padding(
                  //       padding: const EdgeInsets.only(bottom: 8.0),
                  //       child: TextButton(
                  //           style: TextButton.styleFrom(
                  //             splashFactory: NoSplash.splashFactory,
                  //           ),
                  //           onPressed: () {
                  //             Navigator.pushNamed(context, '/info');
                  //           },
                  //           child: SizedBox(
                  //             child: Row(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   SizedBox(
                  //                     child: Row(children: [
                  //                       Padding(
                  //                         padding:
                  //                             const EdgeInsets.only(right: 8.0),
                  //                         child: Icon(Icons.info,
                  //                             color: Theme.of(context)
                  //                                 .colorScheme
                  //                                 .onSecondaryContainer),
                  //                       ),
                  //                       Text(
                  //                         Const.about,
                  //                         style: TextStyle(
                  //                             color: Theme.of(context)
                  //                                 .colorScheme
                  //                                 .onSecondaryContainer),
                  //                       ),
                  //                     ]),
                  //                   ),
                  //                   SizedBox(
                  //                       child: Icon(Icons.chevron_right,
                  //                           color: Theme.of(context)
                  //                               .colorScheme
                  //                               .onSecondaryContainer))
                  //                 ]),
                  //           ))),
                  //   Padding(
                  //       padding: const EdgeInsets.only(bottom: 8.0),
                  //       child: TextButton(
                  //           style: TextButton.styleFrom(
                  //             splashFactory: NoSplash.splashFactory,
                  //           ),
                  //           onPressed: () {
                  //             Navigator.pushNamed(context, '/debug');
                  //           },
                  //           child: SizedBox(
                  //             child: Row(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   SizedBox(
                  //                     child: Row(children: [
                  //                       Padding(
                  //                         padding:
                  //                             const EdgeInsets.only(right: 8.0),
                  //                         child: Icon(Icons.bug_report,
                  //                             color: Theme.of(context)
                  //                                 .colorScheme
                  //                                 .onSecondaryContainer),
                  //                       ),
                  //                       Text(
                  //                         Const.debug,
                  //                         style: TextStyle(
                  //                             color: Theme.of(context)
                  //                                 .colorScheme
                  //                                 .onSecondaryContainer),
                  //                       ),
                  //                     ]),
                  //                   ),
                  //                   SizedBox(
                  //                       child: Icon(Icons.chevron_right,
                  //                           color: Theme.of(context)
                  //                               .colorScheme
                  //                               .onSecondaryContainer))
                  //                 ]),
                  //           ))),
                  // ]),
                  )
            ],
          ),
        ),
      ),
    );
  }
}
