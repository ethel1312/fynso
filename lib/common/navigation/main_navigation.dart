import 'package:flutter/material.dart';
import 'package:fynso/features/agregar/view/registrar_movimientos_screen.dart';
import '../../features/agregar/view/agregar_gasto_screen.dart';
import '../../features/agregar/view/grabar_gasto_screen.dart';
import '../../features/agregar/view/historial_movimientos_screen.dart';
import '../../features/analytics/view/analytics_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../themes/app_color.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const RegistrarMovimientosScreen(),
    const GrabarGastoScreen(),
    const HistorialMovimientosScreen(),
    const AnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE0E0E0), // Línea superior sutil
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          // sin sombra extra
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColor.azulFynso,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note_rounded),
              label: 'Registrar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_rounded),
              label: 'Grabar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_rounded),
              label: 'Analíticas',
            ),
          ],
        ),
      ),
    );
  }
}
