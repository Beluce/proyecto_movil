import 'package:flutter/material.dart';

class SquareTile extends StatefulWidget {
  final Function()? onTap;
  final String imagePath;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<SquareTile> createState() => _SquareTileState();
}

class _SquareTileState extends State<SquareTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: isPressed
              ? []
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          widget.imagePath,
          height: 36,
        ),
      ),
    );
  }
}
