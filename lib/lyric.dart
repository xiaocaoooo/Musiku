import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musiku/utool.dart';
import 'dart:math';
import 'gradient_text.dart';

class LyricType {
  static const int txt = 0;
  static const int lrc = 1;
  static const int eslyric = 2;
}

class Lyrics {
  late String lyrics;
  late List<String> lines;
  String title = "";
  String artist = "";
  String album = "";
  String offset = "";
  String by = "";
  int type = LyricType.txt;
  List<Map<String, dynamic>> lrcs = [];
  static RegExp regExpEsLyric = RegExp(r"<\d{2}:\d{2}\.\d{2}>");
  static RegExp regExpEsLyric2 = RegExp(r"<\d{2}:\d{2}\.\d{2}>.+");
  static RegExp regExpEsLyric3 = RegExp(r"<\d{2}:\d{2}\.\d{2}>[^<]*");
  static RegExp regExpLrc = RegExp(r"\[\d{2}:\d{2}\.\d{2}\]");
  bool inited = false;

  // 构造函数，初始化歌词和按行拆分后的歌词列表
  Lyrics(this.lyrics) {
    lines = lyrics.split('\n');
    lines = lines.where((line) => line.isNotEmpty).toList();

    if (regExpEsLyric.hasMatch(lyrics)) {
      type = LyricType.eslyric;
    } else if (regExpLrc.hasMatch(lyrics)) {
      type = LyricType.lrc;
    }

    if (type != LyricType.txt) {
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].startsWith("[ti:")) {
          title = lines[i].substring(4, lines[i].length - 1);
          continue;
        }
        if (lines[i].startsWith("[ar:")) {
          artist = lines[i].substring(4, lines[i].length - 1);
          continue;
        }
        if (lines[i].startsWith("[al:")) {
          album = lines[i].substring(4, lines[i].length - 1);
          continue;
        }
        if (lines[i].startsWith("[offset:")) {
          offset = lines[i].substring(8, lines[i].length - 1);
          continue;
        }
        if (lines[i].startsWith("[by:")) {
          by = lines[i].substring(4, lines[i].length - 1);
          continue;
        }

        if (type == LyricType.lrc) {
          double startTime =
              processTime(lines[i].substring(1, lines[i].indexOf("]")));
          double endTime = -1;
          if (i < lines.length - 1) {
            // 不是最后一句，结束时间以下一句歌词的开始时间为准
            endTime = processTime(
                lines[i + 1].substring(1, lines[i + 1].indexOf("]")));
          }
          String text = lines[i].substring(lines[i].indexOf("]") + 1);
          // lrcs.add(LyricLine(text, startTime, endTime));
          lrcs.add({
            "startTime": startTime,
            "endTime": endTime,
            "content": [
              {
                "startTime": startTime,
                "endTime": endTime,
                "text": text,
              }
            ],
          });
        } else if (type == LyricType.eslyric) {
          if (regExpEsLyric2.hasMatch(lines[i])) {
            double startTime =
                processTime(lines[i].substring(1, lines[i].indexOf("]")));
            double endTime = -1;
            if (i < lines.length - 1) {
              // 不是最后一句，结束时间以下一句歌词的开始时间为准
              endTime = processTime(
                  lines[i + 1].substring(1, lines[i + 1].indexOf("]")));
            }
            endTime = processTime(lines[i].split("<").last);
            List<Map<String, dynamic>> words = [];
            List<Match> matches = regExpEsLyric3.allMatches(lines[i]).toList();
            for (var i = 0; i < matches.length; i++) {
              Match match = matches[i];
              double wordStartTime = processTime(
                  match.group(0)!.substring(1, match.group(0)!.indexOf(">")));
              String wordText =
                  match.group(0)!.substring(match.group(0)!.indexOf(">") + 1);
              if (i < matches.length - 1) {
                // words.add(LyricWord(
                //     wordText,
                //     wordStartTime,
                //     processTime(matches[i + 1]
                //         .group(0)!
                //         .substring(1, matches[i + 1].group(0)!.indexOf(">")))));
                words.add({
                  "startTime": wordStartTime,
                  "endTime": processTime(matches[i + 1]
                      .group(0)!
                      .substring(1, matches[i + 1].group(0)!.indexOf(">"))),
                  "text": wordText,
                });
              } else {
                // words.add(LyricWord(wordText, wordStartTime, endTime));
                words.add({
                  "startTime": wordStartTime,
                  "endTime": endTime,
                  "text": wordText,
                });
              }
            }
            // endTime=words.last.endTime;
            // lrcs.add(LyricESLyric(startTime, endTime, words));
            lrcs.add({
              "startTime": startTime,
              "endTime": endTime,
              "content": words,
            });
          } else {
            double startTime =
                processTime(lines[i].substring(1, lines[i].indexOf("]")));
            double endTime = -1;
            if (i < lines.length - 1) {
              // 不是最后一句，结束时间以下一句歌词的开始时间为准
              endTime = processTime(
                  lines[i + 1].substring(1, lines[i + 1].indexOf("]")));
            }
            String text = lines[i]
                .substring(lines[i].indexOf("]") + 1, lines[i].indexOf("<"));
            // List<LyricWord> words = [LyricWord(text, startTime, -1)];
            // lrcs.add(LyricESLyric(startTime, endTime, words));
            lrcs.add({
              "startTime": startTime,
              "endTime": endTime,
              "content": [
                {
                  "startTime": startTime,
                  "endTime": endTime,
                  "text": text,
                }
              ],
            });
          }
        }
      }
    }
    inited = true;
  }

  double processTime(String time) {
    // final t = time.substring(1, time.length - 1);
    final t = time
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll("<", "")
        .replaceAll(">", "");
    final List<String> parts = t.split(':');
    final double minutes = double.parse(parts[0]);
    final double seconds = double.parse(parts[1]);
    return minutes * 60 + seconds;
  }
}

class LyricsView extends StatefulWidget {
  List<Map<String, dynamic>> lrcs;
  double time;
  EdgeInsets padding = EdgeInsets.zero;
  double paddingTop = 0;
  ScrollController controller;

  LyricsView(
      {super.key,
      required this.lrcs,
      required this.time,
      required this.padding,
      required this.paddingTop,
      required this.controller});

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Colors.white.withOpacity(0.4);
    final primaryColor = Colors.white.withOpacity(0.8);
    // final secondaryColor = Colors.green;
    // final primaryColor = Colors.red;
    const textStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );
    // const padding=EdgeInsets.zero;

    String previousLyrics = "";
    Map<String, dynamic> lastLyric = {
      "startTime": -1,
      "endTime": -1,
      "content": [
        {"startTime": -1, "endTime": -1, "text": ""}
      ]
    };
    Map<String, dynamic> currentLyric = {
      "startTime": -1,
      "endTime": -1,
      "content": [
        {"startTime": -1, "endTime": -1, "text": ""}
      ]
    };
    Map<String, dynamic> nextLyric = {
      "startTime": -1,
      "endTime": -1,
      "content": [
        {"startTime": -1, "endTime": -1, "text": ""}
      ]
    };
    String laterLyrics = "";
    int crtIdx = 0;

    print(widget.lrcs.length);
    for (var i = 0; i < widget.lrcs.length; i++) {
      if (i == 0 && widget.lrcs[i]["startTime"] < widget.time) {
        nextLyric = widget.lrcs[i];
      }
      if (i != 0 && i != widget.lrcs.length - 1) {
        if (widget.lrcs[i - 1]["endTime"] <= widget.time &&
            widget.lrcs[i + 1]["startTime"] >= widget.time) {
          currentLyric = widget.lrcs[i];
          crtIdx = i;
          if (i < widget.lrcs.length - 1) {
            nextLyric = widget.lrcs[i + 1];
          }
        }
      }
      if (widget.lrcs[i]["endTime"] <= widget.time) {
        if (i == 0) {
          lastLyric = widget.lrcs[i];
          continue;
        }
        previousLyrics +=
            "${previousLyrics == "" ? "" : "\n"}${lastLyric["content"].map((e) => e["text"]).join()}";
        // for (var j = 0; j < lastLyric["content"].length; j++) {
        //   previousLyrics += lastLyric["content"][j]["text"];
        // }
        lastLyric = widget.lrcs[i];
        continue;
      }
      if (widget.lrcs[i]["startTime"] > widget.time) {
        if (i > 1 &&
            widget.lrcs[i - 2]["endTime"] <= widget.time &&
            widget.lrcs[i]["startTime"] >= widget.time) {
          continue;
        }
        // laterLyrics += laterLyrics == "" ? "" : "\n";
        // for (var j = 0; j < widget.lrcs[i]["content"].length; j++) {
        //   laterLyrics += widget.lrcs[i]["content"][j]["text"];
        // }
        laterLyrics +=
            "${laterLyrics == "" ? "" : "\n"}${widget.lrcs[i]["content"].map((e) => e["text"]).join()}";
        continue;
      }
      currentLyric = widget.lrcs[i];
      crtIdx = i;
      if (i < widget.lrcs.length - 1) {
        nextLyric = widget.lrcs[i + 1];
      }
    }
    double progress = 1.0;
    try {
      progress = (widget.time - currentLyric["startTime"]) /
          (currentLyric["endTime"] - currentLyric["startTime"]);
    } catch (e) {
      //
    }
    // String pre = "";
    // String crt = "";
    // String lat = "";
    List<Widget> children = [];
    for (var i = 0; i < currentLyric["content"].length; i++) {
      if (currentLyric["content"][i]["endTime"] < widget.time) {
        // pre += currentLyric["content"][i]["text"];
        children.add(Text(
          currentLyric["content"][i]["text"],
          style: textStyle.copyWith(color: primaryColor),
          // textAlign: TextAlign.start,
        ));
        continue;
      }
      if (currentLyric["content"][i]["startTime"] > widget.time) {
        // lat += currentLyric["content"][i]["text"];
        children.add(Text(
          currentLyric["content"][i]["text"],
          style: textStyle.copyWith(color: secondaryColor),
          // textAlign: TextAlign.start,
        ));
        continue;
      }
      // crt = currentLyric["content"][i]["text"];
      double progress = 1.0;
      try {
        progress = (widget.time - currentLyric["content"][i]["startTime"]) /
            (currentLyric["content"][i]["endTime"] -
                currentLyric["content"][i]["startTime"]);
      } catch (e) {
        //
      }
      children.add(GradientText(
          text: currentLyric["content"][i]["text"],
          style: textStyle,
          gradient: LinearGradient(
            colors: [
              primaryColor,
              secondaryColor,
            ],
            stops: [progress, progress],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )));
    }
    return Padding(
      padding: widget.padding,
      child: SingleChildScrollView(
          controller: widget.controller,
          child: Column(children: [
            SizedBox(
              height: widget.paddingTop,
            ),
            SizedBox(
                width: double.infinity,
                child: Text(
                  previousLyrics,
                  style: textStyle.copyWith(color: primaryColor),
                  textAlign: TextAlign.start,
                )),
            // Wrap(children: [Text(pre, textAlign: TextAlign.start,),GradientText(
            //     text: crt,
            //     style: textStyle,
            //     gradient: LinearGradient(
            //       colors: [
            //         primaryColor,
            //         secondaryColor,
            //       ],
            //       stops: [progress, progress],
            //       begin: Alignment.centerLeft,
            //       end: Alignment.centerRight,
            //     )
            // ),Text(lat, textAlign: TextAlign.start,)],),
            // GradientText(
            //   text: currentLyric["content"].map((e) => e["text"]).join(),
            //   style: textStyle,
            //   gradient: LinearGradient(
            //     colors: [
            //       primaryColor,
            //       secondaryColor,
            //     ],
            //     stops: [progress, progress],
            //     begin: Alignment.centerLeft,
            //     end: Alignment.centerRight,
            //   ),
            // ),
            SizedBox(width: double.infinity, child: Wrap(children: children)),
            SizedBox(
                width: double.infinity,
                child: Text(
                  nextLyric["content"].map((e) => e["text"]).join(),
                  style: textStyle.copyWith(color: secondaryColor),
                  textAlign: TextAlign.start,
                )),
            SizedBox(
                width: double.infinity,
                child: Text(
                  laterLyrics,
                  style: textStyle.copyWith(color: secondaryColor),
                  textAlign: TextAlign.start,
                )),
            const SizedBox(
              height: 3000,
            )
          ])),
    );
  }
}
