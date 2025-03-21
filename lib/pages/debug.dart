import 'package:flutter/material.dart';

class Debug extends StatefulWidget {
  const Debug({super.key});

  @override
  State<Debug> createState() => _DebugState();
}

class _DebugState extends State<Debug> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: Center(
        child: Image.network("http://192.168.31.151:5244/d/SYSTEM-MEMZ-CAO/D/90422/Pictures/pjsk/Miku_16.png")
      ),
    );
  }
}
