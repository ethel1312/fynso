import 'package:flutter/material.dart';
import '../../features/agregar/view/grabar_gasto_screen.dart';
import '../../features/analytics/view/analytics_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../themes/app_color.dart';

//import '../../features/add/view/add_screen.dart'; // placeholder
//import '../../features/search/view/search_screen.dart'; // placeholder
import '../../features/settings/view/settings_screen.dart'; // placeholder

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const GrabarGastoScreen(),
    const AnalyticsScreen(),
    //const SearchScreen(),
    const SettingsScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.azulFynso,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 30),
            label: 'Agregar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analíticas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
