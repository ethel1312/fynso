import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category_item.dart';
import '../models/subcategory_item.dart';

class CategoryService {
  final String baseUrl = 'https://www.fynso.app';

  Future<List<CategoryItem>> getCategories({required String jwt}) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/categories'),
      headers: {'Authorization': 'JWT $jwt'},
    ).timeout(const Duration(seconds: 8));

    if (resp.statusCode != 200) {
      throw Exception('Error al obtener categorías: ${resp.statusCode}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if (decoded['code'] != 1) {
      throw Exception(decoded['message'] ?? 'Error listando categorías');
    }

    final items = (decoded['data']?['items']) ?? [];
    return (items as List).map<CategoryItem>((e) {
      if (e is Map<String, dynamic>) return CategoryItem.fromJson(e);
      if (e is List && e.length >= 2) return CategoryItem.fromList(e);
      throw Exception('Formato de categoría no soportado: $e');
    }).toList();
  }

  Future<List<SubcategoryItem>> getSubcategories({
    required String jwt,
    required int idCategory,
  }) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/categories/$idCategory/subcategories'),
      headers: {'Authorization': 'JWT $jwt'},
    ).timeout(const Duration(seconds: 8));

    if (resp.statusCode != 200) {
      throw Exception('Error al obtener subcategorías: ${resp.statusCode}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if (decoded['code'] != 1) {
      throw Exception(decoded['message'] ?? 'Error listando subcategorías');
    }

    final items = (decoded['data']?['items']) ?? [];
    return (items as List).map<SubcategoryItem>((e) {
      if (e is Map<String, dynamic>) return SubcategoryItem.fromJson(e);
      if (e is List && e.length >= 2) return SubcategoryItem.fromList(e);
      throw Exception('Formato de subcategoría no soportado: $e');
    }).toList();
  }
}
