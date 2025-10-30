import 'package:flutter/material.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text("ExpenseTracker v2.1.0", style: TextStyle(color: Colors.grey)),
        SizedBox(height: 8),
        Text(
          "Terms   •   Privacy   •   Help",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
