class PagoPremium {
  final String message;
  final String? checkoutUrl;

  PagoPremium({required this.message, this.checkoutUrl});

  factory PagoPremium.fromJson(Map<String, dynamic> json) {
    return PagoPremium(
      message: json["message"] ?? '',
      checkoutUrl: json["data"]?["checkout_url"] ?? json["data"]?["init_point"],
    );
  }
}
