import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/themes/app_color.dart';
import '../../../../common/themes/theme_view_model.dart';

class PreferencesCard extends StatefulWidget {
  const PreferencesCard({super.key});

  @override
  State<PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<PreferencesCard> {
  bool pushNotifications = true;
  bool budgetAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = prefs.getBool('push_notifications') ?? true;
      budgetAlerts = prefs.getBool('budget_alerts') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Preferencias",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SwitchListTile(
            title: const Text("Modo oscuro"),
            subtitle: const Text("Activar tema oscuro"),
            value: themeVM.isDarkMode,
            activeColor: AppColor.azulFynso,
            activeTrackColor: AppColor.azulFynso.withOpacity(0.5),
            onChanged: (val) => themeVM.toggleTheme(val),
          ),
          SwitchListTile(
            title: const Text("Notificaciones push"),
            subtitle: const Text("Recibir avisos sobre tus gastos"),
            value: pushNotifications,
            activeColor: AppColor.azulFynso,
            onChanged: (val) {
              setState(() {
                pushNotifications = val;
                if (!val)
                  budgetAlerts = false; // Desactivar alertas si apaga push
              });
              _savePreference('push_notifications', val);
              _savePreference('budget_alerts', budgetAlerts);
            },
          ),

          SwitchListTile(
            title: const Text("Alertas de presupuesto"),
            subtitle: const Text("Avisar cuando superes tu presupuesto"),
            value: budgetAlerts,
            activeColor: AppColor.azulFynso,
            onChanged: pushNotifications
                ? (val) {
                    setState(() => budgetAlerts = val);
                    _savePreference('budget_alerts', val);
                  }
                : null, // Deshabilitado si push está apagado
          ),
        ],
      ),
    );
  }
}
