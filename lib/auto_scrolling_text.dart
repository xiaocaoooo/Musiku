import 'package:flutter/material.dart';

class AutoScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const AutoScrollingText({
    Key? key,
    required this.text,
    this.style,
    this.scrollDuration = const Duration(seconds: 10),
    this.pauseDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _AutoScrollingTextState createState() => _AutoScrollingTextState();
}

class _AutoScrollingTextState extends State<AutoScrollingText>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.scrollDuration,
    );

    // 延迟一段时间后开始滚动
    Future.delayed(widget.pauseDuration, () {
      _startScrolling();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startScrolling() {
    _animationController.forward().then((_) {
      // 滚动完成后，重置滚动位置并再次开始滚动
      _scrollController.jumpTo(0);
      _animationController.reset();
      Future.delayed(widget.pauseDuration, () {
        _startScrolling();
      });
    });

    // 监听动画值的变化，更新滚动位置
    _animationController.addListener(() {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(maxScrollExtent * _animationController.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}