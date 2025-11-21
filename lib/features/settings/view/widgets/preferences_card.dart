import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fynso/data/services/notification_service.dart';

import '../../../../common/themes/app_color.dart';
import '../../../../common/themes/theme_view_model.dart';

class PreferencesCard extends StatefulWidget {
  const PreferencesCard({super.key});

  @override
  State<PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<PreferencesCard> {
  bool pushNotifications = false;
  bool budgetAlerts = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Defaults en false
      pushNotifications = prefs.getBool('push_notifications') ?? false;
      budgetAlerts = prefs.getBool('budget_alerts') ?? false;
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
            onChanged: (val) async {
              if (val) {
                // Quiere encenderlas: pedimos permiso al SO
                final granted =
                await NotificationService.askPermissionsOnce();

                if (!granted) {
                  if (!mounted) return;
                  setState(() {
                    pushNotifications = false;
                    // NO tocamos budgetAlerts: se queda como estaba
                  });
                  await _savePreference('push_notifications', false);
                  // No cambiamos budget_alerts aquí

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No se pudieron activar las notificaciones. '
                            'Por favor habilítalas desde los ajustes del sistema.',
                      ),
                    ),
                  );
                  return;
                }

                // Permiso OK: primera vez -> encender todos los tipos por defecto
                final prefs = await SharedPreferences.getInstance();
                final initialized =
                    prefs.getBool('notif_types_initialized') ?? false;

                bool newBudgetAlerts = budgetAlerts;

                if (!initialized) {
                  newBudgetAlerts = true; // encendemos todas las categorías (por ahora solo esta)
                  await prefs.setBool('budget_alerts', newBudgetAlerts);
                  await prefs.setBool('notif_types_initialized', true);
                }

                setState(() {
                  pushNotifications = true;
                  budgetAlerts = newBudgetAlerts;
                });

                await prefs.setBool('push_notifications', true);
              } else {
                // Apagar master: NO tocamos lo que el usuario tenía en cada tipo
                if (!mounted) return;
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  pushNotifications = false;
                  // budgetAlerts se mantiene (solo que queda inactivo "lógicamente")
                });
                await prefs.setBool('push_notifications', false);
                // No cambiamos budget_alerts aquí
              }
            },
          ),
          SwitchListTile(
            title: const Text("Alertas de presupuesto"),
            subtitle: const Text("Avisar cuando superes tu presupuesto"),
            value: budgetAlerts,
            activeColor: AppColor.azulFynso,
            onChanged: pushNotifications
                ? (val) async {
              setState(() => budgetAlerts = val);
              await _savePreference('budget_alerts', val);
            }
                : null, // 🔒 deshabilitado (gris) si push está apagado
          ),
        ],
      ),
    );
  }
}
