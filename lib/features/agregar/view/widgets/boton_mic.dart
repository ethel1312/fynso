import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const MicButton({
    super.key,
    required this.onPressed,
    this.size = 56,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      child: Icon(Icons.mic, color: iconColor, size: size * 0.6),
    );
  }
}
