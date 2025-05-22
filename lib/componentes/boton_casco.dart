import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const AnimatedButton({super.key,
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  State<AnimatedButton> createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  void _handleTapDown(_) => setState(() => _isPressed = true);
  void _handleTapUp(_) => setState(() => _isPressed = false);
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.teal.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Image.asset(
              widget.image,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
