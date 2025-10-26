import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/monthly_summary.dart';
import '../../../data/repositories/monthly_summary_repository.dart';

class MonthlySummaryViewModel extends ChangeNotifier {
  final MonthlySummaryRepository _repo = MonthlySummaryRepository();

  bool isLoading = false;
  bool isSaving = false;
  String? error;

  MonthlySummary? summary;

  Future<void> load({required String jwt, required int anio, required int mes}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      summary = await _repo.fetchMonthlySummary(jwt: jwt, anio: anio, mes: mes);
    } catch (e) {
      error = e.toString();
      summary = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setLimit({
    required String jwt,
    required int anio,
    required int mes,
    required double limite,
  }) async {
    if (isSaving) return false;
    isSaving = true;
    notifyListeners();
    try {
      await _repo.setMonthlyLimit(jwt: jwt, anio: anio, mes: mes, limite: limite);
      summary = await _repo.fetchMonthlySummary(jwt: jwt, anio: anio, mes: mes);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ------ Helpers de UI ------
  double get limite => summary?.limiteDouble ?? 0.0;
  double get gastado => summary?.gastoDouble ?? 0.0;
  double get restante => (limite > 0) ? (limite - gastado) : 0.0;

  double get progress {
    if (limite <= 0) return 0.0;
    final v = gastado / limite;
    if (v.isNaN || v.isInfinite) return 0.0;
    return v.clamp(0.0, 1.0);
  }

  String get percentUsedLabel {
    if (limite <= 0) return 'Sin presupuesto';
    final p = (progress * 100);
    return '${p.toStringAsFixed(1)}% usado';
  }

  int daysRemaining({DateTime? now}) {
    final _now = now ?? DateTime.now();
    final year = summary?.anio ?? _now.year;
    final month = summary?.mes ?? _now.month;
    final last = DateTime(year, month + 1, 0);
    final diff = last.difference(DateTime(_now.year, _now.month, _now.day)).inDays;
    return diff;
  }

  bool get isClosed => (summary?.estado.toLowerCase() == 'cerrado');
  bool get hasBudget => limite > 0;

  // ====== PREFERENCIAS LOCALES PARA "LÍMITE PREDETERMINADO" ======
  static const _kPrefCarryOver = 'carry_over_default_limit';
  static const _kPrefDefaultLimit = 'default_limit_amount';

  Future<void> setCarryOverPrefs({required bool enabled, double? defaultLimit}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kPrefCarryOver, enabled);
    if (enabled && defaultLimit != null && defaultLimit > 0) {
      await sp.setDouble(_kPrefDefaultLimit, defaultLimit);
    }
  }

  Future<(bool enabled, double amount)> getCarryOverPrefs() async {
    final sp = await SharedPreferences.getInstance();
    final enabled = sp.getBool(_kPrefCarryOver) ?? false;
    final amount = sp.getDouble(_kPrefDefaultLimit) ?? 0.0;
    return (enabled, amount);
  }

  // ====== RECONCILIAR AL ABRIR/REANUDAR LA APP ======
  Future<void> reconcileOnAppOpen({required String jwt, String tzName = 'America/Lima'}) async {
    final now = DateTime.now();
    final (enabled, amount) = await getCarryOverPrefs();
    try {
      await _repo.reconcileMonthly(
        jwt: jwt,
        tzName: tzName,
        nowIso: now.toIso8601String(),
        applyDefaultLimit: enabled,
        defaultLimit: amount,
      );
      // Después de reconciliar, recargar resumen del mes actual
      await load(jwt: jwt, anio: now.year, mes: now.month);
    } catch (e) {
      // No bloqueamos la app si falla; guardamos error y dejamos que la UI lo muestre si hace falta
      error = e.toString();
      notifyListeners();
    }
  }
}
