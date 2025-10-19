class SubcategoryItem {
  final int idSubcategory;
  final String nombre;

  SubcategoryItem({required this.idSubcategory, required this.nombre});

  factory SubcategoryItem.fromJson(Map<String, dynamic> json) {
    return SubcategoryItem(
      idSubcategory: json['id_subcategory'] as int,
      nombre: json['nombre'] as String,
    );
  }

  /// Fallback si el backend retornara arrays (p.ej., [id, nombre])
  factory SubcategoryItem.fromList(List<dynamic> arr) {
    return SubcategoryItem(
      idSubcategory: arr[0] as int,
      nombre: arr[1] as String,
    );
  }
}
