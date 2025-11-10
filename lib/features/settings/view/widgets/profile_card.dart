import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../../common/themes/app_color.dart';
import '../../../../data/services/user_service.dart';
import '../../../home/view_model/monthly_summary_view_model.dart';
import 'package:intl/intl.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final UserService _userService = UserService();
  String? _firstName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');
      final email = prefs.getString('user_email');

      if (jwt != null && jwt.isNotEmpty) {
        // Reutilizar el mismo método que usa home_screen
        final firstName = await _userService.getFirstName(jwt);
        if (mounted) {
          setState(() {
            _firstName = firstName;
            _userEmail = email;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String? name, String? email) {
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0.00', 'es_PE');

    // Crear ViewModel local para obtener el presupuesto
    return ChangeNotifierProvider(
      create: (_) {
        final vm = MonthlySummaryViewModel();
        // Cargar datos del presupuesto
        Future.microtask(() async {
          final prefs = await SharedPreferences.getInstance();
          final jwt = prefs.getString('jwt_token');
          if (jwt != null && jwt.isNotEmpty) {
            await vm.reconcileOnAppOpen(jwt: jwt, tzName: 'America/Lima');
          }
        });
        return vm;
      },
      child: Consumer<MonthlySummaryViewModel>(
        builder: (context, vm, _) {
          final hasData = vm.summary != null;
          final limite = hasData && vm.hasBudget ? vm.limite : null;

          return Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            _getInitials(_firstName, _userEmail),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColor.azulFynso,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nombre",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _firstName ?? _userEmail ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Presupuesto mensual",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                limite != null
                                    ? 'S/ ${numberFormat.format(limite)}'
                                    : 'No configurado',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
