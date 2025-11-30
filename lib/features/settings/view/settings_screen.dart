// lib/features/settings/view/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/custom_button.dart';
import '../../auth/view_model/auth_view_model.dart';
import '../view_model/premium_view_model.dart';
import '../view_model/usuario_premium_view_model.dart';
import '../../../common/widgets/custom_text_title.dart';
import 'widgets/profile_card.dart';
import 'widgets/preferences_card.dart';
import 'widgets/security_privacy_card.dart';
import 'widgets/premium_card.dart';
import 'widgets/settings_footer.dart';

class SettingsScreen extends StatefulWidget {
  final bool scrollToPremium;

  const SettingsScreen({super.key, this.scrollToPremium = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.scrollToPremium) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
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
                    color: Theme.of(context).cardColor,
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
                  child: CustomButton(
                    text: "Cerrar sesión",
                    backgroundColor: Colors.redAccent,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      final authVM = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );
                      await authVM.logout();

                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
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
