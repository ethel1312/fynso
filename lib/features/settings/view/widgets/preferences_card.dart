import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            onChanged: (val) {
              themeVM.toggleTheme(val); // Guarda y actualiza el tema
            },
          ),
          SwitchListTile(
            title: const Text("Notificaciones push"),
            subtitle: const Text("Recibir avisos sobre tus gastos"),
            value: pushNotifications,
            activeColor: AppColor.azulFynso,
            // Color del switch
            activeTrackColor: AppColor.azulFynso.withOpacity(0.5),
            onChanged: (val) => setState(() => pushNotifications = val),
          ),
          SwitchListTile(
            title: const Text("Alertas de presupuesto"),
            subtitle: const Text("Avisar cuando superes tu presupuesto"),
            value: budgetAlerts,
            activeColor: AppColor.azulFynso,
            // Color del switch
            activeTrackColor: AppColor.azulFynso.withOpacity(0.5),
            onChanged: (val) => setState(() => budgetAlerts = val),
          ),
        ],
      ),
    );
  }
}
