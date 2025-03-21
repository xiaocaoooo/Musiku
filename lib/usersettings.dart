import 'dart:ui';
import 'package:musiku/utool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _usernameKey = 'username';
  static const String _primaryColor = 'primaryColor';
  static const String _homePageIndex = 'homePageIndex';
  static const String _languageKey = 'language';
  static const String _foldersKey = 'folders';
  static const String _musicInfoKey = 'musicInfo';
  static const String _musicListKey = 'musicList';
  static const String _theme = 'theme';

  // 初始化用户设置，设置默认值
  static Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_isDarkModeKey)) {
      await prefs.setInt(_isDarkModeKey, -1);
    }
    if (!prefs.containsKey(_usernameKey)) {
      await prefs.setString(_usernameKey, 'Miku');
    }
    if (!prefs.containsKey(_primaryColor)) {
      await prefs.setInt(_primaryColor, const Color(0xFF39c5BB).value);
    }
    if (!prefs.containsKey(_homePageIndex)) {
      await prefs.setInt(_homePageIndex, 0);
    }
    if (!prefs.containsKey(_languageKey)) {
      await prefs.setString(_languageKey, 'zh_cn');
    }
    if (!prefs.containsKey(_foldersKey)) {
      await prefs.setStringList(_foldersKey, ['/storage/emulated/0/Music/']);
    }
    if (!prefs.containsKey(_musicInfoKey)) {
      await prefs.setStringList(_musicInfoKey, []);
    }
    if (!prefs.containsKey(_musicListKey)) {
      await prefs.setStringList(_musicListKey, []);
    }
    if (!prefs.containsKey(_theme)) {
      await prefs.setInt(_theme, 0);
    }
  }

  static Future<int> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_isDarkModeKey) ?? -1;
  }

  static Future<void> setIsDarkMode(int isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_isDarkModeKey, isDarkMode);
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'Miku';
  }

  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  static Future<int> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_primaryColor) ?? const Color(0xFF39c5BB).value;
  }

  static Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColor, color.value);
  }

  static Future<int> getHomePageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_homePageIndex) ?? 0;
  }

  static Future<void> setHomePageIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_homePageIndex, index);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'zh_cn';
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<List<String>> getFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_foldersKey) ?? [];
  }

  static Future<void> setFolders(List<String> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_foldersKey, folders);
  }

  static Future<Map<String, dynamic>?> getMusicInfo(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final info = prefs.getStringList(_musicInfoKey);
    final list = prefs.getStringList(_musicListKey);
    if (list!.contains(filePath)) {
      final index = list.indexOf(filePath);
      final infoList = info![index].split('<!SEPARATOR!>');
      return {
        'title': infoList[0],
        'artist': infoList[1],
        'album': infoList[2],
        'filePath': infoList[3],
        'duration': int.parse(infoList[4]),
        'lastModified': int.parse(infoList[5]),
      };
    }
    return null;
  }

  static Future<void> setMusicInfo(String filePath,
      [Map<String, dynamic>? info]) async {
    if (info == null) {
      info = await getMusicMetadata(filePath);
      if (info == null) {
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final infoList = prefs.getStringList(_musicInfoKey);
    final list = prefs.getStringList(_musicListKey);
    if (list!.contains(filePath)) {
      final index = list.indexOf(filePath);
      infoList![index] =
          '${info['title']}<!SEPARATOR!>${info['artist']}<!SEPARATOR!>${info['album']}<!SEPARATOR!>$filePath<!SEPARATOR!>${info['duration']}<!SEPARATOR!>${info["lastModified"]}';
      await prefs.setStringList(_musicInfoKey, infoList);
    } else {
      list.add(filePath);
      infoList!.add(
          '${info['title']}<!SEPARATOR!>${info['artist']}<!SEPARATOR!>${info['album']}<!SEPARATOR!>$filePath<!SEPARATOR!>${info['duration']}<!SEPARATOR!>${info["lastModified"]}');
      await prefs.setStringList(_musicInfoKey, infoList);
      await prefs.setStringList(_musicListKey, list);
    }
  }

  static Future<List> getMusicList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_musicListKey) ?? [];
  }

  static Future<int> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_theme) ?? 0;
  }

  static Future<void> setTheme(int theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_theme, theme);
  }
}
