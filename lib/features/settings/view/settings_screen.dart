import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fynso/data/services/user_service.dart';
import 'package:fynso/features/settings/view/widgets/profile_card.dart';
import 'package:fynso/features/settings/view/widgets/preferences_card.dart';
import 'package:fynso/features/settings/view/widgets/security_privacy_card.dart';
import 'package:fynso/features/settings/view/widgets/premium_card.dart';
import 'package:fynso/features/settings/view/widgets/settings_footer.dart';
import '../../../common/widgets/custom_text_title.dart';
import '../../auth/view_model/auth_view_model.dart';
import '../view_model/premium_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<String?> _nombreFuture;

  Future<String?> _loadNombre() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null || jwt.isEmpty) return null;

    final svc = UserService();
    return await svc.getFirstName(jwt);
  }

  @override
  void initState() {
    super.initState();
    _nombreFuture = _loadNombre();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PremiumViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextTitle("Configuración"),
                      const SizedBox(height: 6),
                      const Text(
                        "Personaliza tu experiencia y gestiona tu cuenta",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                // PROFILE CARD (con nombre real)
                FutureBuilder<String?>(
                  future: _nombreFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final nombre = snapshot.data ?? "Usuario";
                    final iniciales = nombre.isNotEmpty
                        ? nombre
                              .trim()
                              .split(' ')
                              .map((e) => e[0])
                              .take(2)
                              .join()
                              .toUpperCase()
                        : "U";

                    return ProfileCard(
                      nombre: nombre,
                      presupuesto: "\$3,500",
                      iniciales: iniciales,
                    );
                  },
                ),

                const SizedBox(height: 20),
                const PreferencesCard(),
                const SizedBox(height: 20),
                const SecurityPrivacyCard(),
                const SizedBox(height: 20),
                const PremiumCard(),
                const SizedBox(height: 20),

                // FOOTER
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Center(child: SettingsFooter()),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // BOTÓN CERRAR SESIÓN
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "Cerrar sesión",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final authVM = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );
                      await authVM.logout();

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
