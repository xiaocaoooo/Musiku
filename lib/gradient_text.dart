import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText({
    super.key,
    required this.text,
    required this.gradient,
    this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child:ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.start,
        ),
      )
    );
  }
}