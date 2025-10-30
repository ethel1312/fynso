import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/premium_view_model.dart';

class PremiumCard extends StatefulWidget {
  const PremiumCard({super.key});

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  @override
  void initState() {
    super.initState();
    // Al cargar la card, verificamos si el usuario es premium
    Future.microtask(
      () => Provider.of<PremiumViewModel>(
        context,
        listen: false,
      ).verificarEstadoPremium(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PremiumViewModel>(context);

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
                    viewModel.isPremium
                        ? "✨ Tu suscripción premium está activa"
                        : "Desbloquea funciones avanzadas y reportes exclusivos.",
                    style: TextStyle(
                      fontSize: 14,
                      color: viewModel.isPremium
                          ? Colors.green[700]
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            viewModel.isPremium
                ? const Icon(Icons.verified, color: Colors.green)
                : ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final error = await viewModel.iniciarSuscripcion();
                            if (error != null) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(error)));
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
