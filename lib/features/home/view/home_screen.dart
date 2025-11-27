import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/features/home/view/widgets/add_button.dart';
import 'package:fynso/features/home/view/widgets/donut_chart_card.dart';
import 'package:fynso/features/home/view/widgets/summary_card.dart';
import 'package:fynso/features/home/view/widgets/transactions_card.dart';
import 'package:fynso/data/services/user_service.dart';

// nuevos imports
import 'package:fynso/common/widgets/fynso_card_dialog.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/data/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<String?> _firstNameFuture;

  Future<String?> _loadFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null || jwt.isEmpty) return null;

    final svc = UserService();
    return await svc.getFirstName(jwt);
  }

  @override
  void initState() {
    super.initState();
    _firstNameFuture = _loadFirstName();

    // Esperamos al primer frame para mostrar el diálogo (cuando la UI ya está cargada)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowNotifDialog();
    });
  }

  Future<void> _maybeShowNotifDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool('notif_dialog_shown') ?? false;

    // Si ya lo mostramos antes, no lo volvemos a mostrar
    if (alreadyShown) return;

    // Marcamos como mostrado
    await prefs.setBool('notif_dialog_shown', true);

    if (!mounted) return;

    await showFynsoCardDialog<void>(
      context,
      title: 'Activa tus notificaciones',
      message:
      'Te avisaremos cuando tu gasto por voz haya terminado de procesarse '
          'y cuando te acerques a tu presupuesto mensual.',
      icon: Icons.notifications_active_outlined,
      actions: [
        // 🔹 Botón "Más tarde"
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColor.azulFynso),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () {
            Navigator.pop(context); // cierra el diálogo

            // Aviso de dónde activarlas después
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Cuando quieras, puedes activar las notificaciones en '
                      'Perfil > Preferencias > Notificaciones push.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          },
          child: const Text('Más tarde'),
        ),

        // 🔹 Botón "Activar ahora"
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.azulFynso,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () async {
            Navigator.pop(context); // cierra el diálogo

            // Pedimos permisos al SO
            final granted = await NotificationService.askPermissionsOnce();

            if (!granted) {
              // Si el usuario dijo que NO
              await prefs.setBool('push_notifications', false);
              // NO tocamos budget_alerts (se queda como estaba, normalmente false)

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No se pudieron activar las notificaciones. '
                        'Puedes habilitarlas luego desde los ajustes del sistema '
                        'y desde Perfil > Preferencias.',
                  ),
                  duration: Duration(seconds: 5),
                ),
              );
              return;
            }

            // Permiso OK: primera vez -> encender todos los tipos por defecto
            final initialized =
                prefs.getBool('notif_types_initialized') ?? false;

            if (!initialized) {
              await prefs.setBool('budget_alerts', true);
              await prefs.setBool('notif_types_initialized', true);
            }

            await prefs.setBool('push_notifications', true);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notificaciones activadas correctamente.'),
                duration: Duration(seconds: 3),
              ),
            );
          },
          child: const Text('Activar ahora'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna con textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String?>(
                          future: _firstNameFuture,
                          builder: (context, snap) {
                            final saludo =
                            (snap.connectionState ==
                                ConnectionState.done &&
                                snap.hasData &&
                                (snap.data ?? '').isNotEmpty)
                                ? "Hola, ${snap.data}!"
                                : "Hola!";
                            return CustomTextTitle(saludo);
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Controla tus gastos sabiamente",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const AddButton(),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SummaryCard(),
            const SizedBox(height: 20),
            DonutChartCard(),
            const SizedBox(height: 20),
            const TransactionsCard(),
          ],
        ),
      ),
    );
  }
}
