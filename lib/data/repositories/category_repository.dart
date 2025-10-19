import '../models/category_item.dart';
import '../models/subcategory_item.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService _service = CategoryService();

  Future<List<CategoryItem>> fetchCategories(String jwt) {
    return _service.getCategories(jwt: jwt);
  }

  Future<List<SubcategoryItem>> fetchSubcategories(String jwt, int idCategory) {
    return _service.getSubcategories(jwt: jwt, idCategory: idCategory);
  }
}
