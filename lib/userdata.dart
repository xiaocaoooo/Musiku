import 'dart:io';
import 'dart:convert'; // 导入dart:convert库，用于JSON编码和解码
import 'package:path_provider/path_provider.dart'; // 导入path_provider库，用于获取应用程序目录
import 'package:path/path.dart' as path_lib; // 导入path库，并使用别名 path_lib，用于路径操作

class UserData{
  String filepath; // 声明字符串类型的变量 filepath，用于存储文件路径

  // 构造函数，接收文件路径作为参数
  UserData(this.filepath);

  // 异步函数 get，用于从文件中读取JSON数据并解析为Map
  Future<Map> get() async {
    Directory dataDir = await getApplicationDocumentsDirectory(); // 获取应用程序的文档目录
    File file = File(path_lib.join(dataDir.path, filepath)); // 创建文件对象，指定文件路径
    // 检查文件是否存在，如果不存在则创建空文件
    if (!await file.exists()) {
      await file.create(); // 创建文件
      return {}; // 文件不存在时返回空Map
    }
    try {
      String contents = await file.readAsString(); // 异步读取文件内容为字符串
      // 检查文件内容是否为空，如果为空则返回空Map
      if (contents.isEmpty) {
        return {}; // 文件内容为空时返回空Map
      }
      Map jsonData = jsonDecode(contents); // 使用jsonDecode函数解析JSON字符串为Map对象
      return jsonData; // 返回解析后的JSON数据Map
    } catch (e) {
      // 捕获JSON解析过程中可能发生的错误，例如文件内容不是合法的JSON格式
      // print('Error parsing JSON: $e'); // 打印错误信息到控制台
      return {}; // 解析出错时返回空Map，作为错误处理
    }
  }

  // 异步函数 set，用于将Map数据编码为JSON字符串并写入文件
  Future<void> set(Map data) async {
    Directory dataDir = await getApplicationDocumentsDirectory(); // 获取应用程序的文档目录
    // 创建文件目录，基于应用程序文档目录和filepath的文件名部分
    Directory directory = Directory(path_lib.join(dataDir.path, path_lib.dirname(filepath)));
    await directory.create(recursive: true); // 创建目录，如果父目录不存在也会一并创建
    File file = File(path_lib.join(dataDir.path, filepath)); // 创建文件对象，指定文件路径
    // print("userdata: ${file.path} $data");
    try {
      String jsonString = jsonEncode(data); // 使用jsonEncode函数将Map数据编码为JSON字符串
      // print("userdata: $jsonString");
      await file.writeAsString(jsonString); // 异步将JSON字符串写入文件
    } catch (e) {
      // 捕获文件写入或JSON编码过程中可能发生的错误
      // print('Error writing JSON: $e'); // 打印错误信息到控制台
      // 你可以选择在这里抛出异常，或者进行其他错误处理，例如返回错误状态
    }
  }
}