class PremiumStatusResponse {
  final int idUsuario;
  final bool isPremium;

  PremiumStatusResponse({
    required this.idUsuario,
    required this.isPremium,
  });

  factory PremiumStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PremiumStatusResponse(
      idUsuario: (data['id_usuario'] as int?) ?? 0,
      isPremium: (data['is_premium'] as bool?) ?? false,
    );
  }
}
