import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';

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
      style: TextButton.styleFrom(foregroundColor: AppColor.azulFynso),
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
