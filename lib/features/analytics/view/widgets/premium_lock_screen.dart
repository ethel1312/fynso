import 'package:flutter/material.dart';

class PremiumLockScreen extends StatelessWidget {
  final VoidCallback onUpgradePressed;

  const PremiumLockScreen({
    super.key,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de candado premium
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.amber[700],
              ),
            ),

            const SizedBox(height: 32),

            // Título
            Text(
              'Contenido Premium',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Descripción
            Text(
              'Las analíticas avanzadas están disponibles exclusivamente para usuarios Premium.',
              style: TextStyle(
                fontSize: 16,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Lista de beneficios
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildBenefit(
                      context,
                      icon: Icons.analytics_outlined,
                      text: 'Reportes detallados de gastos',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefit(
                      context,
                      icon: Icons.insights_outlined,
                      text: 'Recomendaciones con IA',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefit(
                      context,
                      icon: Icons.trending_up_rounded,
                      text: 'Tendencias y predicciones',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefit(
                      context,
                      icon: Icons.category_outlined,
                      text: 'Análisis por categorías',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botón de upgrade
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpgradePressed,
                icon: const Icon(Icons.star, color: Colors.white),
                label: const Text(
                  'Actualizar a Premium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(BuildContext context,
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
