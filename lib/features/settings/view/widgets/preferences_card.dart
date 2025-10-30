import 'package:flutter/material.dart';

class PreferencesCard extends StatefulWidget {
  const PreferencesCard({super.key});

  @override
  State<PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<PreferencesCard> {
  bool isDarkMode = false;
  bool pushNotifications = true;
  bool budgetAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Preferences",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Switch to dark theme"),
            value: isDarkMode,
            onChanged: (val) => setState(() => isDarkMode = val),
          ),
          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Get notified about expenses"),
            value: pushNotifications,
            onChanged: (val) => setState(() => pushNotifications = val),
          ),
          SwitchListTile(
            title: const Text("Budget Alerts"),
            subtitle: const Text("Alert when overspending"),
            value: budgetAlerts,
            onChanged: (val) => setState(() => budgetAlerts = val),
          ),
        ],
      ),
    );
  }
}
