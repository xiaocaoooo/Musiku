import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Debug extends StatefulWidget {
  const Debug({super.key});

  @override
  State<Debug> createState() => _DebugState();
}

class _DebugState extends State<Debug> {
  Directory? currentDirectory;
  List<FileSystemEntity> files = [];
  bool isLoading = false;
  String errorMessage = '';
  String currentPath = '/storage/emulated/0';

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadFiles();
  }

  Future<void> _requestPermissionAndLoadFiles() async {
    PermissionStatus status = await Permission.audio.request();
    if (status.isGranted) {
      currentDirectory = Directory(currentPath);
      _loadFiles();
    } else {
      _requestPermission();
      setState(() => errorMessage = '存储权限被拒绝');
    }
  }
  Future<void> _requestPermission() async {
    final status = await Permission.storage.request();
    if (status.isDenied) {
      // 显示提示信息并允许用户重新请求
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('需要存储权限'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _requestPermission(); // 重新请求
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadFiles() async {
    setState(() => isLoading = true);
    try {
      final list = await currentDirectory!.list().toList();
      list.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        return aIsDir == bIsDir
            ? a.path.compareTo(b.path)
            : aIsDir ? -1 : 1;
      });
      setState(() => files = list);
    } catch (e) {
      setState(() => errorMessage = '无法读取目录: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _navigateTo(Directory dir) {
    currentDirectory = dir;
    currentPath = dir.path;
    _loadFiles();
  }

  void _navigateUp() {
    if (currentDirectory?.parent.path == '/storage/emulated') return;
    currentDirectory = currentDirectory?.parent;
    currentPath = currentDirectory!.path;
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPath.split('/').last),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPath != '/storage/emulated/0' ? _navigateUp : null,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage));
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final entity = files[index];
        final isDir = entity is Directory;
        return ListTile(
          leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file),
          title: Text(entity.path.split('/').last),
          onTap: isDir ? () => _navigateTo(entity) : null,
        );
      },
    );
  }
}