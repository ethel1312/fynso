class ApiResponse {
  final int code;
  final Map<String, dynamic> data;
  final String message;

  ApiResponse({required this.code, required this.data, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] ?? 0,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}
