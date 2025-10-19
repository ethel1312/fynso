class CategoryItem {
  final int idCategory;
  final String nombre;

  CategoryItem({required this.idCategory, required this.nombre});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      idCategory: json['id_category'] as int,
      nombre: json['nombre'] as String,
    );
  }

  /// Fallback si el backend retornara arrays (p.ej., [id, nombre])
  factory CategoryItem.fromList(List<dynamic> arr) {
    return CategoryItem(
      idCategory: arr[0] as int,
      nombre: arr[1] as String,
    );
  }
}
