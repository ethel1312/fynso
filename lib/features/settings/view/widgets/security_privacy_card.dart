import 'package:flutter/material.dart';

class SecurityPrivacyCard extends StatelessWidget {
  const SecurityPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: const [
          ListTile(
            title: Text(
              "Security & Privacy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text("Manage Payment Methods"),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Settings"),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
