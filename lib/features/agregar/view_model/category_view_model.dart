import 'package:flutter/material.dart';
import '../../../data/models/category_item.dart';
import '../../../data/models/subcategory_item.dart';
import '../../../data/repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  bool loadingCategories = false;
  bool loadingSubcategories = false;
  String? error;

  List<CategoryItem> categories = [];
  List<SubcategoryItem> subcategories = [];

  CategoryItem? selectedCategory;
  SubcategoryItem? selectedSubcategory;

  // 👇 Cache: recuerda para qué categoría ya cargaste subcategorías
  int? _lastLoadedCategoryId;

  Future<void> init({
    required String jwt,
    String? initialCategoryName,
    String? initialSubcategoryName,
  }) async {
    await loadCategories(jwt: jwt);

    // Seleccionar categoría/subcategoría inicial según nombres de la transacción
    if (initialCategoryName != null && categories.isNotEmpty) {
      selectedCategory = _firstWhereOrNull<CategoryItem>(
        categories,
            (c) => c.nombre.toLowerCase() == initialCategoryName.toLowerCase(),
      );
      if (selectedCategory != null) {
        await loadSubcategories(jwt: jwt, idCategory: selectedCategory!.idCategory);
        if (initialSubcategoryName != null && subcategories.isNotEmpty) {
          selectedSubcategory = _firstWhereOrNull<SubcategoryItem>(
            subcategories,
                (s) => s.nombre.toLowerCase() == initialSubcategoryName.toLowerCase(),
          );
        }
      }
    }
    notifyListeners();
  }

  Future<void> loadCategories({required String jwt}) async {
    loadingCategories = true;
    error = null;
    notifyListeners();
    try {
      categories = await _repo.fetchCategories(jwt);
    } catch (e) {
      error = 'No se pudieron cargar categorías';
      categories = [];
    } finally {
      loadingCategories = false;
      notifyListeners();
    }
  }

  /// Carga subcategorías. Si ya están en cache para esa categoría y no se pide `force`,
  /// NO vuelve a llamar al backend y apaga cualquier spinner.
  Future<void> loadSubcategories({
    required String jwt,
    required int idCategory,
    bool force = false,
  }) async {
    if (!force &&
        _lastLoadedCategoryId == idCategory &&
        subcategories.isNotEmpty) {
      // Ya tenemos datos de esta categoría; asegúrate de que no quede "cargando"
      loadingSubcategories = false;
      notifyListeners();
      return;
    }

    loadingSubcategories = true;
    error = null;
    subcategories = [];
    selectedSubcategory = null;
    notifyListeners();

    try {
      subcategories = await _repo.fetchSubcategories(jwt, idCategory);
      _lastLoadedCategoryId = idCategory;
    } catch (e) {
      error = 'No se pudieron cargar subcategorías';
      subcategories = [];
    } finally {
      loadingSubcategories = false;
      notifyListeners();
    }
  }

  /// Selecciona categoría y solo recarga subcategorías si:
  /// - cambiaste de categoría, o
  /// - no hay subcategorías cargadas todavía.
  Future<void> selectCategoryById({
    required String jwt,
    required int idCategory,
  }) async {
    // Si ya es la misma categoría y tenemos subcategorías en cache para ese id, evita refetch
    if (selectedCategory?.idCategory == idCategory &&
        _lastLoadedCategoryId == idCategory &&
        subcategories.isNotEmpty) {
      selectedCategory = _firstWhereOrNull<CategoryItem>(
        categories,
            (c) => c.idCategory == idCategory,
      ) ??
          selectedCategory;
      notifyListeners();
      return;
    }

    // Cambia selección y carga subcategorías (hará fetch si no están en cache)
    selectedCategory = _firstWhereOrNull<CategoryItem>(
      categories,
          (c) => c.idCategory == idCategory,
    );
    await loadSubcategories(jwt: jwt, idCategory: idCategory);
  }

  void selectSubcategoryById(int idSubcategory) {
    selectedSubcategory = _firstWhereOrNull<SubcategoryItem>(
      subcategories,
          (s) => s.idSubcategory == idSubcategory,
    );
    notifyListeners();
  }

  T? _firstWhereOrNull<T>(Iterable<T> list, bool Function(T) test) {
    for (final e in list) {
      if (test(e)) return e;
    }
    return null; // (sin depender de package:collection)
  }
}
