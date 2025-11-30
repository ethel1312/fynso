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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              // Mismo color que el fondo para que la línea sea casi invisible
              color: Theme.of(context).colorScheme.surface,
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
          unselectedItemColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
