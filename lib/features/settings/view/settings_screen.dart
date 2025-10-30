import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <<-- agregar
import 'package:fynso/features/settings/view/widgets/profile_card.dart';
import 'package:fynso/features/settings/view/widgets/preferences_card.dart';
import 'package:fynso/features/settings/view/widgets/security_privacy_card.dart';
import 'package:fynso/features/settings/view/widgets/premium_card.dart';
import 'package:fynso/features/settings/view/widgets/settings_footer.dart';
import '../../../common/widgets/custom_text_title.dart';
import '../view_model/premium_view_model.dart'; // <<-- agregar

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PremiumViewModel(), // <<-- Provider agregado
      child: Scaffold(
        backgroundColor: Colors.grey[50],
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextTitle("Configuración"),
                          const SizedBox(height: 4),
                          const Text(
                            "Personaliza tu experiencia y gestiona tu cuenta",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // TARJETAS DE CONFIGURACIÓN
              const ProfileCard(),
              const SizedBox(height: 20),

              const PreferencesCard(),
              const SizedBox(height: 20),

              const SecurityPrivacyCard(),
              const SizedBox(height: 20),

              const PremiumCard(), // <<-- ahora encontrará el Provider
              const SizedBox(height: 30),

              const SettingsFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
