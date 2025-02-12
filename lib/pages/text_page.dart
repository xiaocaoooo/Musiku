import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  final String text;
  const TextPage({super.key, required this.text});
  @override
  State<TextPage> createState() => _TextPageState();
}
class _TextPageState extends State<TextPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Text(widget.text),
        ),
      ),
    );
  }
}