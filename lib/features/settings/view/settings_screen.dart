import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late final PremiumViewModel _premiumViewModel;
  late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();

    // 🔹 Creamos los viewmodels solo una vez
    _premiumViewModel = PremiumViewModel();
    _authViewModel = AuthViewModel();

    // 🔹 Verificamos estado premium solo al iniciar
    _premiumViewModel.verificarEstadoPremium();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _premiumViewModel),
        ChangeNotifierProvider.value(value: _authViewModel),
      ],
      child: const _SettingsBody(),
    );
  }
}

// 🔹 Separar cuerpo real en widget Stateless
class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  children: const [
                    CustomTextTitle("Perfil"),
                    SizedBox(height: 6),
                    Text(
                      "Personaliza tu experiencia y gestiona tu cuenta",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // TARJETAS DE CONFIGURACIÓN
              const ProfileCard(),
              SizedBox(height: 20),

              const PreferencesCard(),
              SizedBox(height: 20),

              const SecurityPrivacyCard(),
              SizedBox(height: 20),

              const PremiumCard(), // 🔹 Ahora se actualizará correctamente
              SizedBox(height: 20),

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
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Center(child: SettingsFooter()),
                  ),
                ),
              ),

              SizedBox(height: 30),

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

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
