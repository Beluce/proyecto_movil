import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedRainbowText extends StatefulWidget {
  final String text;
  final double fontSize;

  const AnimatedRainbowText(this.text, {super.key, this.fontSize = 40});

  @override
  State<AnimatedRainbowText> createState() => _AnimatedRainbowTextState();
}

class _AnimatedRainbowTextState extends State<AnimatedRainbowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ],
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
