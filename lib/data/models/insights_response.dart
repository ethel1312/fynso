import 'insight_recommendation.dart';

class InsightsResponse {
  final String generatedAt;
  final bool llmUsed;
  final List<InsightRecommendation> items;

  InsightsResponse({
    required this.generatedAt,
    required this.llmUsed,
    required this.items,
  });

  factory InsightsResponse.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>;
    final list = (data['items'] as List? ?? [])
        .map((e) => InsightRecommendation.fromJson(e))
        .toList();
    return InsightsResponse(
      generatedAt: (data['generated_at'] ?? '').toString(),
      llmUsed: (data['llm_used'] as bool?) ?? false,
      items: list,
    );
  }
}



