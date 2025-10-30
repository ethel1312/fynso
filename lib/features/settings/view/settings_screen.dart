// lib/features/settings/view/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/view_model/auth_view_model.dart';
import '../view_model/premium_view_model.dart';
import '../view_model/usuario_premium_view_model.dart';
import '../../../common/widgets/custom_text_title.dart';
import 'widgets/profile_card.dart';
import 'widgets/preferences_card.dart';
import 'widgets/security_privacy_card.dart';
import 'widgets/premium_card.dart';
import 'widgets/settings_footer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UsuarioPremiumViewModel()..verificarEstadoPremium(),
        ),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PremiumViewModel()),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextTitle("Perfil"),
                      SizedBox(height: 6),
                      Text(
                        "Personaliza tu experiencia y gestiona tu cuenta",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const ProfileCard(),
                const SizedBox(height: 20),
                const PreferencesCard(),
                const SizedBox(height: 20),
                const SecurityPrivacyCard(),
                const SizedBox(height: 20),
                const PremiumCard(),
                const SizedBox(height: 20),
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
                // Aquí tu contenido
              ],
            ),
          ),
        ),
      ),
    );
  }
}
