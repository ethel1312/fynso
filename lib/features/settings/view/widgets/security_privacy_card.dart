import 'package:flutter/material.dart';

class SecurityPrivacyCard extends StatelessWidget {
  const SecurityPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: const [
          ListTile(
            title: Text(
              "Seguridad y privacidad",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text("Gestionar métodos de pago"),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Cambiar contraseña"),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Configuración de privacidad"),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
