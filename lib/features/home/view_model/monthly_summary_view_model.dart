import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/monthly_summary.dart';
import '../../../data/repositories/monthly_summary_repository.dart';
import '../../../data/repositories/monthly_limit_repository.dart';
import '../../../data/services/notification_service.dart';

class MonthlySummaryViewModel extends ChangeNotifier {
  final MonthlySummaryRepository _summaryRepo = MonthlySummaryRepository();
  final MonthlyLimitRepository _limitRepo = MonthlyLimitRepository();

  bool isLoading = false;
  bool isSaving = false;
  String? error;

  MonthlySummary? summary;

  Future<void> load({
    required String jwt,
    required int anio,
    required int mes,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      summary = await _summaryRepo.fetchMonthlySummary(
        jwt: jwt,
        anio: anio,
        mes: mes,
      );
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
      await _summaryRepo.setMonthlyLimit(
        jwt: jwt,
        anio: anio,
        mes: mes,
        limite: limite,
      );
      summary = await _summaryRepo.fetchMonthlySummary(
        jwt: jwt,
        anio: anio,
        mes: mes,
      );
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

  double get presupuestoReal => limite + (summary?.ingresosDouble ?? 0.0);

  double get restanteReal =>
      (presupuestoReal - gastado).clamp(0.0, double.infinity);

  double get progressReal {
    if (presupuestoReal <= 0) return 0.0;
    final v = gastado / presupuestoReal;
    if (v.isNaN || v.isInfinite) return 0.0;
    return v.clamp(0.0, 1.0);
  }

  String get percentUsedLabelReal {
    if (presupuestoReal <= 0) return 'Sin presupuesto';
    final p = (progressReal * 100);
    return '${p.toStringAsFixed(1)}% usado';
  }

  int daysRemaining({DateTime? now}) {
    final _now = now ?? DateTime.now();
    final year = summary?.anio ?? _now.year;
    final month = summary?.mes ?? _now.month;
    final last = DateTime(year, month + 1, 0);
    final diff = last
        .difference(DateTime(_now.year, _now.month, _now.day))
        .inDays;
    return diff;
  }

  bool get isClosed => (summary?.estado.toLowerCase() == 'cerrado');

  bool get hasBudget => limite > 0;

  // ====== “Predeterminado” en BACKEND ======

  Future<(bool enabled, double amount)> getCarryOverPrefs({
    required String jwt,
  }) async {
    try {
      final res = await _limitRepo.getDefaultMonthlyLimit(jwt: jwt);
      return (res.enabled, res.defaultLimit);
    } catch (_) {
      return (false, 0.0);
    }
  }

  Future<void> setCarryOverPrefs({
    required String jwt,
    required bool enabled,
    required double defaultLimit,
  }) async {
    await _limitRepo.setDefaultMonthlyLimit(
      jwt: jwt,
      enabled: enabled,
      defaultLimit: defaultLimit,
    );
  }

  // ====== RECONCILIAR AL ABRIR/REANUDAR LA APP ======
  Future<void> reconcileOnAppOpen({
    required String jwt,
    String tzName = 'America/Lima',
  }) async {
    final now = DateTime.now();
    // lee “predeterminado” del backend
    final (enabled, amount) = await getCarryOverPrefs(jwt: jwt);

    try {
      await _limitRepo.reconcile(
        jwt: jwt,
        tzName: tzName,
        applyDefaultLimit: enabled,
        defaultLimit: amount.toStringAsFixed(2),
      );
      // recargar resumen del mes actual
      await load(jwt: jwt, anio: now.year, mes: now.month);
      // aquí se verifica y se lanza la alerta si corresponde
      await verificarPresupuesto();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> checkBudgetAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final alertEnabled = prefs.getBool('budget_alerts') ?? true;
    if (!alertEnabled) return; // Si no está activado, no hacer nada

    if (gastado >= limite) {
      // Aquí mostrar notificación o pop-up de alerta
    }
  }

  Future<void> verificarPresupuesto() async {
    if (!hasBudget) return;

    final porcentaje = progress * 100;

    if (porcentaje >= 100) {
      await NotificationService.show(
        title: '💸 Presupuesto superado',
        body:
            'Has gastado más de tu límite mensual de S/.${limite.toStringAsFixed(2)}',
        isBudgetAlert: true,
      );
    } else if (porcentaje >= 90) {
      await NotificationService.show(
        title: '⚠️ Presupuesto casi completo',
        body:
            'Ya usaste el ${porcentaje.toStringAsFixed(0)}% de tu presupuesto mensual.',
        isBudgetAlert: true,
      );
    }
  }
}
