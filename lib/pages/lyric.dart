import 'package:flutter/material.dart';

class LyricPage extends StatefulWidget {
  LyricPage({super.key});
  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("LyricPage"),
      ),
    );
  }

}