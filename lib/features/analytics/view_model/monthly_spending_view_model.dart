import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fynso/data/models/monthly_spending_trend.dart';
import 'package:fynso/data/repositories/analytics_repository.dart';

class MonthlySpendingViewModel extends ChangeNotifier {
  final AnalyticsRepository _repo = AnalyticsRepository();

  bool loading = false;
  String? error;
  MonthlySpendingTrendResponse? data;

  Future<void> load({required String jwt}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await _repo.fetchMonthlySpendingTrend(jwt: jwt);
    } catch (e) {
      error = e.toString();
      data = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String monthAbbrES(int year, int month) {
    final s = DateFormat('MMM', 'es').format(DateTime(year, month, 1));
    return s[0].toUpperCase() + s.substring(1);
  }
}


