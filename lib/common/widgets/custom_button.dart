import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Widget? icon;
  final Future<void> Function()? onPressed; // 👈 permite async

  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 335,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed == null
            ? null
            : () async {
                await onPressed!(); // 👈 ejecuta async correctamente
              },
        icon: icon,
        label: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
