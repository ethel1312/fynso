import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:fynso/data/repositories/analytics_repository.dart';
import 'package:fynso/data/services/analytics_service.dart';

class CategoryBreakdownListViewModel extends ChangeNotifier {
  final AnalyticsRepository _repo = AnalyticsRepository();

  // Estado
  bool loading = false;
  String? error;
  CategoryBreakdownResponse? data;

  // Auth
  String _jwt = '';

  // Mes/Año visibles (inicializados para evitar LateInitializationError)
  int anio = DateTime.now().year;
  int mes  = DateTime.now().month;

  // Rango disponible (según backend /available_range)
  static const String _baseUrl = 'https://www.fynso.app';
  int? _minYear;              // primer año con transacciones
  int? _minMonth;             // primer mes con transacciones
  int? _maxYearTx;            // último año con transacciones
  int? _maxMonthTx;           // último mes con transacciones
  int? _maxAllowedYear;       // tope técnico (próximo mes)
  int? _maxAllowedMonth;      // tope técnico (próximo mes)

  // Flag para permitir un mes futuro (si el usuario tiene default_monthly_limit)
  bool hasUserDefaultLimit = false;

  // ===== Lifecycle =====
  Future<void> init({
    required String jwt,
    int? anio,
    int? mes,
  }) async {
    _jwt = jwt;
    if (anio != null) this.anio = anio;
    if (mes  != null) this.mes  = mes;

    await _fetchAvailableRange();
    await load(); // llena 'data' y 'hasUserDefaultLimit'
  }

  Future<void> load() async {
    if (_jwt.isEmpty) {
      error = 'Sesión no iniciada';
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      final resp = await _repo.fetchCategoryBreakdown(
        jwt: _jwt,
        anio: anio,
        mes: mes,
        top: 5,
      );
      data = resp;
      hasUserDefaultLimit = resp.hasUserDefaultLimit;
    } catch (e) {
      error = 'No se pudo cargar el desglose';
      data = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ===== available_range del backend =====
  Future<void> _fetchAvailableRange() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/transactions/available_range');
      final resp = await http.get(
        uri,
        headers: {'Authorization': 'JWT $_jwt', 'Accept': 'application/json'},
      );
      if (resp.statusCode != 200) return;
      final root = jsonDecode(resp.body) as Map<String, dynamic>;
      if ((root['code'] ?? 0) != 1) return;
      final data = (root['data'] as Map<String, dynamic>?) ?? {};

      _minYear         = data['min_year'] as int?;
      _minMonth        = data['min_month'] as int?;
      _maxYearTx       = data['max_year'] as int? ?? data['max_allowed_year'] as int?;     // fallback
      _maxMonthTx      = data['max_month'] as int? ?? data['max_allowed_month'] as int?;   // fallback
      _maxAllowedYear  = data['max_allowed_year'] as int?;
      _maxAllowedMonth = data['max_allowed_month'] as int?;
    } catch (_) {}
  }

  // ===== utils de fecha =====
  DateTime _addMonths(DateTime base, int delta) {
    final y = base.year;
    final m = base.month + delta;
    final newY = y + ((m - 1) ~/ 12);
    final newM = ((m - 1) % 12) + 1;
    return DateTime(newY, newM, 1);
  }

  int _ymCompare(int y1, int m1, int y2, int m2) {
    if (y1 != y2) return y1.compareTo(y2);
    return m1.compareTo(m2);
  }

  /// Rango permitido para el picker:
  /// - un mes ANTES del mínimo con transacciones
  /// - un mes DESPUÉS del máximo con transacciones (solo si hasUserDefaultLimit = true)
  /// - clamp por tope técnico max_allowed_* (próximo mes)
  Map<String, int> allowedRangeForPicker() {
    final now = DateTime.now();

    final minTx = (_minYear != null && _minMonth != null)
        ? DateTime(_minYear!, _minMonth!, 1)
        : DateTime(now.year, now.month, 1);
    final maxTx = (_maxYearTx != null && _maxMonthTx != null)
        ? DateTime(_maxYearTx!, _maxMonthTx!, 1)
        : DateTime(now.year, now.month, 1);

    // un mes antes del mínimo
    final minAllowed = _addMonths(minTx, -1);

    // un mes después del máximo (solo si hay default)
    DateTime logicalMax = hasUserDefaultLimit ? _addMonths(maxTx, 1) : maxTx;

    // clamp por tope técnico (próximo mes)
    final maxAllowedRaw = (_maxAllowedYear != null && _maxAllowedMonth != null)
        ? DateTime(_maxAllowedYear!, _maxAllowedMonth!, 1)
        : _addMonths(DateTime(now.year, now.month, 1), 1);

    final cmp = _ymCompare(
      logicalMax.year, logicalMax.month,
      maxAllowedRaw.year, maxAllowedRaw.month,
    );
    final maxAllowed = (cmp <= 0) ? logicalMax : maxAllowedRaw;

    return {
      'minY': minAllowed.year,
      'minM': minAllowed.month,
      'maxY': maxAllowed.year,
      'maxM': maxAllowed.month,
    };
  }
}
