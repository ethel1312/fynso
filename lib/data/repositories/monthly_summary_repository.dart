import '../models/monthly_summary.dart';
import '../services/monthly_summary_service.dart';

class MonthlySummaryRepository {
  final MonthlySummaryService _service = MonthlySummaryService();

  Future<MonthlySummary> fetchMonthlySummary({
    required String jwt,
    required int anio,
    required int mes,
  }) {
    return _service.getMonthlySummary(jwt: jwt, anio: anio, mes: mes);
  }

  Future<void> setMonthlyLimit({
    required String jwt,
    required int anio,
    required int mes,
    required double limite,
  }) {
    return _service.setMonthlyLimit(jwt: jwt, anio: anio, mes: mes, limite: limite);
  }

  Future<void> closeMonth({
    required String jwt,
    required int anio,
    required int mes,
  }) {
    return _service.closeMonth(jwt: jwt, anio: anio, mes: mes);
  }

  Future<void> reconcileMonthly({
    required String jwt,
    required String tzName,
    required String nowIso,
    required bool applyDefaultLimit,
    required double defaultLimit,
  }) {
    return _service.reconcileMonthly(
      jwt: jwt,
      tzName: tzName,
      nowIso: nowIso,
      applyDefaultLimit: applyDefaultLimit,
      defaultLimit: defaultLimit,
    );
  }
}
