import 'package:flutter/material.dart';

class CustomTextTitle extends StatelessWidget {
  final String text;

  const CustomTextTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
    );
  }
}
