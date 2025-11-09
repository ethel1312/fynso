// lib/features/settings/view/widgets/premium_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../pago/view/pago_screen.dart';
import '../../view_model/premium_view_model.dart';
import '../../view_model/usuario_premium_view_model.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PremiumViewModel>(context);
    final vm = Provider.of<UsuarioPremiumViewModel>(context);

    return Card(
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fynso Premium",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vm.isPremium
                        ? "✨ Tu suscripción premium está activa"
                        : "Desbloquea funciones avanzadas y reportes exclusivos.",
                    style: TextStyle(
                      fontSize: 14,
                      color: vm.isPremium ? Colors.green[700] : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            vm.isPremium
                ? const Icon(Icons.verified, color: Colors.green)
                : ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final result = await viewModel.iniciarSuscripcion();
                            if (result != null &&
                                result is String &&
                                result.startsWith("http")) {
                              // ✅ Navegar al WebView con la URL del pago
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PagoScreen(url: result),
                                ),
                              );
                            } else if (result != null) {
                              // ⚠️ Mostrar error si no es una URL
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(result)));
                            }
                          },
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Mejorar"),
                  ),
          ],
        ),
      ),
    );
  }
}
