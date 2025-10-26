import '../services/monthly_limit_service.dart';

class MonthlyLimitRepository {
  final MonthlyLimitService _service = MonthlyLimitService();

  Future<void> reconcile({
    required String jwt,
    required String tzName,
    bool applyDefaultLimit = false,
    String defaultLimit = '0.00',
  }) {
    return _service.reconcile(
      jwt: jwt,
      tzName: tzName,
      applyDefaultLimit: applyDefaultLimit,
      defaultLimit: defaultLimit,
    );
  }
}
