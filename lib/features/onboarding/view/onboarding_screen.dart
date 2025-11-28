import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/navigation/main_navigation.dart';
import '../../auth/view/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Registro de gastos por voz',
      'description':
      'Añade tus gastos simplemente hablando. Fynso los escucha, los interpreta y los guarda al instante.',
      'icon': 'mic',
    },
    {
      'title': 'Categorización inteligente',
      'description':
      'Fynso identifica la categoría de tus gastos automáticamente para que no pierdas tiempo organizándolos.',
      'icon': 'auto_awesome',
    },
    {
      'title': 'Reportes claros y útiles',
      'description':
      'Revisa tus gastos del mes en gráficos fáciles de entender. Identifica rápidamente en qué estás gastando más.',
      'icon': 'monitoring',
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    final jwt = prefs.getString('jwt_token') ?? '';
    if (jwt.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'mic':
        return Icons.mic;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'monitoring':
        return Icons.bar_chart;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Solo el contenido va dentro del PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) {
                  final page = _pages[index];
                  return Column(
                    children: [
                      // Fondo azul con icono blanco
                      Container(
                        width: double.infinity,
                        height: size.height * 0.5,
                        color: AppColor.azulFynso,
                        child: Center(
                          child: Icon(
                            _getIcon(page['icon']),
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      ),

                      // Card blanca con título y descripción
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  page['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  page['description'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 🔹 Botones e indicadores fijos abajo
            Padding
              (
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Saltar'),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                          (dotIndex) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == dotIndex ? 12 : 8,
                        height: _currentPage == dotIndex ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == dotIndex
                              ? AppColor.azulFynso
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Empezar'
                          : 'Siguiente',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
