class TranscribeResponse {
  final String transcript;
  final Map<String, dynamic> extracted;
  final Map<String, dynamic> monthSummary;

  TranscribeResponse({
    required this.transcript,
    required this.extracted,
    required this.monthSummary,
  });

  factory TranscribeResponse.fromJson(Map<String, dynamic> json) {
    return TranscribeResponse(
      transcript: json['data']['transcript'] ?? '',
      extracted: json['data']['extracted'] ?? {},
      monthSummary: json['data']['month_summary'] ?? {},
    );
  }
}
