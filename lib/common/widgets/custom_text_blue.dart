import 'package:flutter/material.dart';

class CustomTextBlue extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isBold;

  const CustomTextBlue({
    super.key,
    required this.text,
    required this.onPressed,
    this.isBold = true, // Por defecto en negrita
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
