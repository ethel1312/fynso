import 'package:flutter/material.dart';
import '../change_password_screen.dart';

class SecurityPrivacyCard extends StatelessWidget {
  const SecurityPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Seguridad y privacidad",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.credit_card),
            title: Text("Gestionar métodos de pago"),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Cambiar contraseña"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Configuración de privacidad"),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
