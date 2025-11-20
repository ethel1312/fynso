class PremiumStatusResponse {
  final bool isPremium;
  final String? estadoSuscripcion;
  final String? subscriptionId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  PremiumStatusResponse({
    required this.isPremium,
    this.estadoSuscripcion,
    this.subscriptionId,
    this.fechaInicio,
    this.fechaFin,
  });

  factory PremiumStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return PremiumStatusResponse(
      isPremium: (data['is_premium'] as bool?) ?? false,
      estadoSuscripcion: data['estado_suscripcion'] as String?,
      subscriptionId: data['subscription_id'] as String?,
      fechaInicio: _parseDate(data['fecha_inicio']),
      fechaFin: _parseDate(data['fecha_fin']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
