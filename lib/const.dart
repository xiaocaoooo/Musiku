import 'package:musiku/usersettings.dart';

class Const {
  static bool initialized = false;

  static String version = "v1.0.0";
  static int versionCode = 2001;

  static List<String> languages = ["en", "zh_cn"];

  static String appName = "musiku";
  static String home = "Home";
  static String search = "Search";
  static String music = "Music";
  static String playlist = "Playlist";
  static String more = "More";
  static String settings = "Settings";
  static String about = "About";
  static String language = "Language";
  static String theme = "Theme";
  static String darkTheme = "Dark";
  static String lightTheme = "Light";
  static String systemTheme = "System";
  static String primaryColor = "Primary Color";
  static String debug = "Debug";
  static String foldersSettings = "Folders Settings";
  static String addItem = "Add Item";
  static String enterFolderPath = "Enter Folder Path";
  static String cancel = "Cancel";
  static String ok = "OK";
  static String all = "All";

  static Future<void> init() async {
    if (!initialized) {
      await UserSettings.initSettings();
      String lang = await UserSettings.getLanguage();
      if (lang == "zh_cn") {
        appName = ZhCn.appName;
        home = ZhCn.home;
        search = ZhCn.search;
        music = ZhCn.music;
        playlist = ZhCn.playlist;
        more = ZhCn.more;
        settings = ZhCn.settings;
        about = ZhCn.about;
        language = ZhCn.language;
        theme = ZhCn.theme;
        darkTheme = ZhCn.darkTheme;
        lightTheme = ZhCn.lightTheme;
        systemTheme = ZhCn.systemTheme;
        primaryColor = ZhCn.primaryColor;
        debug = ZhCn.debug;
        foldersSettings = ZhCn.foldersSettings;
        addItem = ZhCn.addItem;
        enterFolderPath = ZhCn.enterFolderPath;
        cancel = ZhCn.cancel;
        ok = ZhCn.ok;
        all = ZhCn.all;
      } else {
        appName = En.appName;
        home = En.home;
        search = En.search;
        music = En.music;
        playlist = En.playlist;
        more = En.more;
        settings = En.settings;
        about = En.about;
        language = En.language;
        theme = En.theme;
        darkTheme = En.darkTheme;
        lightTheme = En.lightTheme;
        systemTheme = En.systemTheme;
        primaryColor = En.primaryColor;
        debug = En.debug;
        foldersSettings = En.foldersSettings;
        addItem = En.addItem;
        enterFolderPath = En.enterFolderPath;
        cancel = En.cancel;
        ok = En.ok;
        all = En.all;
      }
    }
  }
}

class ZhCn {
  static String appName = "MusIKU";
  static String home = "首页";
  static String search = "搜索";
  static String music = "音乐";
  static String playlist = "列表";
  static String more = "更多";
  static String settings = "设置";
  static String about = "关于";
  static String language = "语言";
  static String theme = "主题";
  static String darkTheme = "深色";
  static String lightTheme = "浅色";
  static String systemTheme = "跟随系统";
  static String primaryColor = "主色调";
  static String debug = "调试";
  static String foldersSettings = "文件夹设置";
  static String addItem = "添加项目";
  static String enterFolderPath = "请输入文件夹路径";
  static String cancel = "取消";
  static String ok = "确定";
  static String all = "全部";
}

class En {
  static String appName = "MusIKU";
  static String home = "Home";
  static String search = "Search";
  static String music = "Music";
  static String playlist = "Playlist";
  static String more = "More";
  static String settings = "Settings";
  static String about = "About";
  static String language = "Language";
  static String theme = "Theme";
  static String darkTheme = "Dark";
  static String lightTheme = "Light";
  static String systemTheme = "System";
  static String primaryColor = "Primary Color";
  static String debug = "Debug";
  static String foldersSettings = "Folders Settings";
  static String addItem = "Add Item";
  static String enterFolderPath = "Enter Folder Path";
  static String cancel = "Cancel";
  static String ok = "OK";
  static String all = "All";
}
