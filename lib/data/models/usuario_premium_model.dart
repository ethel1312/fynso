class UsuarioPremium {
  final int idUsuario;
  final bool isPremium;

  UsuarioPremium({required this.idUsuario, required this.isPremium});

  factory UsuarioPremium.fromJson(Map<String, dynamic> json) {
    return UsuarioPremium(
      idUsuario: json['id_usuario'] ?? 0,
      isPremium: json['is_premium'] ?? false,
    );
  }
}
