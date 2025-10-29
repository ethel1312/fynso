import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/transaction_response.dart';
import '../../../data/models/transactions_filter.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/models/category_item.dart';
import '../../../data/models/subcategory_item.dart';

class HistorialGastosViewModel extends ChangeNotifier {
  final TransactionRepository _txRepo = TransactionRepository();
  final CategoryRepository _catRepo = CategoryRepository();

  bool isLoading = false;
  String? error;
  List<TransactionResponse> transactions = [];

  // Mes visible por defecto = hoy
  int anio = DateTime.now().year;
  int mes  = DateTime.now().month;

  // Paginación simple (si luego quieres infinite scroll)
  int page = 1;
  int size = 100;

  // Filtros
  TransactionsFilter filter = const TransactionsFilter();

  // Catálogo para filtros
  List<CategoryItem> categories = [];
  List<SubcategoryItem> subcategories = [];

  // Rango disponible (opcional: si quieres mostrar límites de date picker)
  DateTime? minDateAvailable;
  DateTime? maxDateAvailable;

  int _reqSeq = 0; // número de secuencia para evitar respuestas viejas

  Future<String?> _getJwt() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('jwt_token');
  }

  Future<void> initCatalogs() async {
    try {
      final jwt = await _getJwt();
      if (jwt == null || jwt.isEmpty) return;
      categories = await _catRepo.fetchCategories(jwt);
      // subcategories se carga lazy cuando se elige categoría
      notifyListeners();
    } catch (_) {
      // silencioso
    }
  }

  Future<void> loadSubcategories(int idCategory) async {
    try {
      final jwt = await _getJwt();
      if (jwt == null || jwt.isEmpty) return;
      subcategories = await _catRepo.fetchSubcategories(jwt, idCategory);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadTransactions({String? jwt, int? anio, int? mes}) async {
    final _jwt = jwt ?? await _getJwt();
    if (_jwt == null || _jwt.isEmpty) return;

    final mySeq = ++_reqSeq;   // ⬅️ secuencia de este request
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final yy = anio ?? this.anio;
      final mm = mes  ?? this.mes;

      final items = await _txRepo.fetchTransactions(
        jwt: _jwt,
        anio: yy,
        mes: mm,
        page: page,
        size: size,
        filter: filter,
      );

      // Si llegó una respuesta más nueva, descarta esta
      if (mySeq != _reqSeq) return;

      transactions = items;
    } catch (e) {
      if (mySeq != _reqSeq) return; // descarta errores de respuestas viejas
      error = e.toString();
      transactions = [];
    } finally {
      if (mySeq == _reqSeq) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // Cambiar mes visible (con límites "futuros" si quieres)
  void changeMonth(int newYear, int newMonth) {
    anio = newYear;
    mes  = newMonth;
    page = 1;
    notifyListeners();
  }

  // Aplicar filtros y recargar
  Future<void> applyFilter(TransactionsFilter newFilter) async {
    filter = newFilter;
    page = 1;
    await loadTransactions();
  }

  // Reset de filtros
  Future<void> clearFilters() async {
    filter = const TransactionsFilter();
    page = 1;
    await loadTransactions();
  }
}
