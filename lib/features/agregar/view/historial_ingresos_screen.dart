import 'dart:convert';
import 'dart:io' show HttpDate;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:fynso/common/config.dart';
import 'package:fynso/common/themes/app_color.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/features/agregar/view/widgets/ingreso_card.dart';

class HistorialIngresosScreen extends StatefulWidget {
  final bool showAppBar;

  const HistorialIngresosScreen({super.key, this.showAppBar = true});

  @override
  State<HistorialIngresosScreen> createState() =>
      _HistorialIngresosScreenState();
}

class _IncomeItem {
  final int idIncome;
  final double amount;
  final String fecha; // ISO o similar
  final String hora; // "HH:mm:ss" o "HH:mm"
  final String? notes;

  _IncomeItem({
    required this.idIncome,
    required this.amount,
    required this.fecha,
    required this.hora,
    this.notes,
  });
}

class _HistorialIngresosScreenState extends State<HistorialIngresosScreen> {
  static const String _baseUrl = Config.baseUrl;

  bool _loading = true;
  String? _error;
  List<_IncomeItem> _items = [];

  int _anio = DateTime.now().year;
  int _mes = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token') ?? '';
      if (jwt.isEmpty) {
        setState(() {
          _error = 'No se encontró token de usuario.';
          _loading = false;
        });
        return;
      }

      final uri = Uri.parse(
        '$_baseUrl/api/incomes/list?anio=$_anio&mes=$_mes',
      );

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'JWT $jwt',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode != 200) {
        final bodyStr = resp.body;
        final preview =
        bodyStr.length > 200 ? bodyStr.substring(0, 200) : bodyStr;
        setState(() {
          _error = 'Error HTTP ${resp.statusCode}: $preview';
          _loading = false;
        });
        return;
      }

      final root = jsonDecode(resp.body) as Map<String, dynamic>;
      if ((root['code'] ?? 0) != 1) {
        setState(() {
          _error = root['message'] ?? 'No se pudo cargar el historial';
          _loading = false;
        });
        return;
      }

      final data = (root['data'] as List<dynamic>? ?? []);
      final list = data.map((raw) {
        final m = raw as Map<String, dynamic>;
        return _IncomeItem(
          idIncome: m['id_income'] as int,
          amount: double.tryParse(m['amount'].toString()) ?? 0.0,
          fecha: m['fecha'] as String,
          hora: m['hora'] as String,
          notes: m['notes'] as String?,
        );
      }).toList();

      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar ingresos: $e';
        _loading = false;
      });
    }
  }

  // ========= utils fechas =========

  DateTime? _parseFlexible(String rawDate, String rawTime) {
    try {
      final joined = '$rawDate $rawTime';
      final iso = DateTime.tryParse(joined);
      if (iso != null) return iso;
    } catch (_) {}

    final isoDate = DateTime.tryParse(rawDate);
    if (isoDate != null) return isoDate;

    try {
      return HttpDate.parse(rawDate);
    } catch (_) {}

    final re = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m = re.firstMatch(rawDate);
    if (m != null) {
      final y = int.parse(m.group(1)!);
      final mm = int.parse(m.group(2)!);
      final d = int.parse(m.group(3)!);
      return DateTime(y, mm, d);
    }

    final re2 = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final m2 = re2.firstMatch(rawDate);
    if (m2 != null) {
      final d = int.parse(m2.group(1)!);
      final mm = int.parse(m2.group(2)!);
      final y = int.parse(m2.group(3)!);
      return DateTime(y, mm, d);
    }
    return null;
  }

  Map<String, List<_IncomeItem>> _groupBySection(List<_IncomeItem> list) {
    final today = DateTime.now();
    DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);
    final t0 = onlyDate(today);
    final y1 = t0.subtract(const Duration(days: 1));
    final weekAgo = t0.subtract(const Duration(days: 7));

    final map = <String, List<_IncomeItem>>{
      'Fechas futuras': [],
      'Hoy': [],
      'Ayer': [],
      'Semana pasada': [],
      'Anteriores': [],
    };

    for (final inc in list) {
      final d = _parseFlexible(inc.fecha, inc.hora);
      if (d == null) {
        map['Anteriores']!.add(inc);
        continue;
      }
      final dd = DateTime(d.year, d.month, d.day);

      if (dd.isAfter(t0)) {
        map['Fechas futuras']!.add(inc);
      } else if (dd == t0) {
        map['Hoy']!.add(inc);
      } else if (dd == y1) {
        map['Ayer']!.add(inc);
      } else if (dd.isAfter(weekAgo) && dd.isBefore(y1)) {
        map['Semana pasada']!.add(inc);
      } else {
        map['Anteriores']!.add(inc);
      }
    }
    return map;
  }

  // ========= Month nav =========

  void _changeMonth(int delta) {
    final newDate = DateTime(_anio, _mes + delta, 1);
    setState(() {
      _anio = newDate.year;
      _mes = newDate.month;
    });
    _loadIncomes();
  }

  String get _monthLabel {
    final s = DateFormat('MMMM yyyy', 'es').format(DateTime(_anio, _mes, 1));
    return s[0].toUpperCase() + s.substring(1);
  }

  // 🔹 Total de ingresos del mes actual
  double get _totalIngresosMes {
    return _items.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  Widget _buildTotalCard() {
    final total = _totalIngresosMes;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.savings_outlined,
            color: Colors.green[700],
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tus ingresos de $_monthLabel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========= Build =========
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.showAppBar
            ? AppBar(
          title: const CustomTextTitle('Historial de ingresos'),
          elevation: 1,
        )
            : null,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final grouped = _groupBySection(_items);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
        title: const CustomTextTitle('Historial de ingresos'),
        elevation: 1,
      )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
                color: AppColor.azulFynso,
              ),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColor.azulFynso),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                  ),
                  onPressed: null,
                  child: Text(
                    _monthLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
                color: AppColor.azulFynso,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ] else if (_items.isEmpty) ...[
            const SizedBox(height: 48),
            const Center(child: Text('No hay ingresos registrados')),
          ] else ...[
            // 🔹 Tarjeta de total mensual
            _buildTotalCard(),
            const SizedBox(height: 16),

            // 🔹 Secciones (Fechas futuras, Hoy, etc.) usando IngresoCard
            for (final section in [
              'Fechas futuras',
              'Hoy',
              'Ayer',
              'Semana pasada',
              'Anteriores',
            ])
              if ((grouped[section] ?? []).isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    section,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: section == 'Fechas futuras'
                          ? Colors.blue[700]
                          : Colors.black,
                    ),
                  ),
                ),
                ...grouped[section]!.map(
                      (inc) {
                    return IngresoCard(
                      amount: inc.amount,
                      fecha: inc.fecha,
                      hora: inc.hora,
                      notes: inc.notes,
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/detalleIngreso',
                          arguments: inc.idIncome,
                        );

                        if (result == 'deleted' || result == 'updated') {
                          _loadIncomes();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
          ],
        ],
      ),
    );
  }
}
