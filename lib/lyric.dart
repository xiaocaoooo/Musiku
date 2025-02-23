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
  List<Lrc> lrcs = [];

  // 构造函数，初始化歌词和按行拆分后的歌词列表
  Lyrics(this.lyrics) {
    lines = lyrics.split('\n');
    lines = lines.where((line) => line.isNotEmpty).toList();

    if (RegExp(r"<\d{2}:\d{2}\.\d{2}>").hasMatch(lyrics)) {
      type = LyricType.eslyric;
    } else if (RegExp(r"\[\d{2}:\d{2}\.\d{2}\]").hasMatch(lyrics)) {
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
          lrcs.add(LyricLine(text, startTime, endTime));
        } else if (type == LyricType.eslyric) {
          if (RegExp(r"<\d{2}:\d{2}\.\d{2}>.+").hasMatch(lines[i])) {
            double startTime =
                processTime(lines[i].substring(1, lines[i].indexOf("]")));
            double endTime = -1;
            if (i < lines.length - 1) {
              // 不是最后一句，结束时间以下一句歌词的开始时间为准
              endTime = processTime(
                  lines[i + 1].substring(1, lines[i + 1].indexOf("]")));
            }
            endTime = processTime("${lines[i].split("<").last}");
            List<LyricWord> words = [];
            List<Match> matches = RegExp(r"<\d{2}:\d{2}\.\d{2}>[^<]*")
                .allMatches(lines[i])
                .toList();
            for (var i = 0; i < matches.length; i++) {
              Match match = matches[i];
              double wordStartTime = processTime(
                  match.group(0)!.substring(1, match.group(0)!.indexOf(">")));
              String wordText =
                  match.group(0)!.substring(match.group(0)!.indexOf(">") + 1);
              if (i < matches.length - 1) {
                words.add(LyricWord(
                    wordText,
                    wordStartTime,
                    processTime(matches[i + 1]
                        .group(0)!
                        .substring(1, matches[i + 1].group(0)!.indexOf(">")))));
              } else {
                words.add(LyricWord(wordText, wordStartTime, endTime));
              }
            }
            // endTime=words.last.endTime;
            lrcs.add(LyricESLyric(startTime, endTime, words));
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
            List<LyricWord> words = [LyricWord(text, startTime, -1)];
            lrcs.add(LyricESLyric(startTime, endTime, words));
          }
        }
      }
    }
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

class Lrc {}

class LyricLine extends Lrc {
  String text;
  double startTime;
  double endTime;

  LyricLine(this.text, this.startTime, this.endTime);
}

class LyricESLyric extends Lrc {
  double startTime;
  double endTime;
  List<LyricWord> words;

  LyricESLyric(this.startTime, this.endTime, this.words);
}

class LyricWord {
  String text;
  double startTime;
  double endTime;

  LyricWord(this.text, this.startTime, this.endTime);
}

class Lyric extends StatefulWidget {
  dynamic lrc;
  double time;

  Lyric(this.lrc, this.time);

  @override
  State<Lyric> createState() => _LyricState();
}

class _LyricState extends State<Lyric> {
  @override
  Widget build(BuildContext context) {
    final secondaryColor = Colors.white.withOpacity(0.4);
    final primaryColor = Colors.white.withOpacity(0.8);
    const textStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );
    const padding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 28.0);

    if (widget.lrc.endTime != -1 && widget.time > widget.lrc.endTime) {
      if (widget.lrc is LyricLine) {
        return Padding(
          padding: padding,
          child: Container(
            child: Text(widget.lrc.text,
                style: textStyle.copyWith(color: primaryColor)),
          ),
        );
      } else if (widget.lrc is LyricESLyric) {
        return Padding(
          padding: padding,
          child: Container(
            child: Text(widget.lrc.words.map((word) => word.text).join(),
                style: textStyle.copyWith(color: primaryColor)),
          ),
        );
      }
    } else if (widget.time < widget.lrc.startTime) {
      if (widget.lrc is LyricLine) {
        return Padding(
          padding: padding,
          child: Container(
            child: Text(widget.lrc.text,
                style: textStyle.copyWith(color: secondaryColor)),
          ),
        );
      } else if (widget.lrc is LyricESLyric) {
        return Padding(
          padding: padding,
          child: Container(
            child: Text(
              widget.lrc.words.map((word) => word.text).join(),
              style: textStyle.copyWith(color: secondaryColor),
            ),
            // child: ListView.builder(
            //   scrollDirection: Axis.horizontal,
            //   // shrinkWrap: true,
            //   // physics: NeverScrollableScrollPhysics(),
            //   itemCount: widget.lrc.words.length,
            //   itemBuilder: (context, index) {
            //     final word = widget.lrc.words[index];
            //     return Text(word.text,
            //         style: textStyle.copyWith(color: secondaryColor));
            //   },
            // ),
          ),
        );
      }
    }
    final progress = (widget.time - widget.lrc.startTime) /
        (widget.lrc.endTime - widget.lrc.startTime);
    // final progress = (Global.player.player.duration!.inSeconds.toDouble() - widget.lrc.startTime) /
    //     (widget.lrc.endTime - widget.lrc.startTime);
    if (widget.lrc == null) {
      return Padding(
        padding: padding,
        child: Container(),
      );
    } else if (widget.lrc is LyricLine) {
      return Padding(
        padding: padding,
        child: Container(
          child: GradientText(
            text: widget.lrc.text,
            style: textStyle,
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              stops: [progress, progress],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      );
    } else if (widget.lrc is LyricESLyric) {
      return Padding(
        padding: padding,
        child: Container(
          child: Builder(builder: (context) {
            List<Widget> children = [];
            for (var i = 0; i < widget.lrc.words.length; i++) {
              if (widget.time > widget.lrc.words[i].endTime) {
                children.add(Text(
                    widget.lrc.words[i].text +
                        widget.lrc.words[i].endTime.toString(),
                    style: textStyle.copyWith(color: Colors.red)));
              } else if (widget.time < widget.lrc.words[i].startTime) {
                children.add(Text(widget.lrc.words[i].text,
                    style: textStyle.copyWith(color: secondaryColor)));
              } else {
                children.add(Text(widget.lrc.words[i].text,
                    style: textStyle.copyWith(color: Colors.green)));
                // final wordProgress =
                //     (widget.time - widget.lrc.words[i].startTime) /
                //         (widget.lrc.words[i].endTime -
                //             widget.lrc.words[i].startTime);
                // children.add(GradientText(
                //     text: widget.lrc.words[i].text,
                //     style: textStyle,
                //     gradient: LinearGradient(
                //       colors: [primaryColor, secondaryColor],
                //       stops: [wordProgress, wordProgress],
                //       begin: Alignment.centerLeft,
                //       end: Alignment.centerRight,
                //     )));
              }
            }
            children.add(Text(progress.toString()));
            return Wrap(direction: Axis.horizontal, children: children);
          }),
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Container(),
    );
  }
}
