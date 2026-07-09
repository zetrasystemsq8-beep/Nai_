class DailyBriefing {
  final String content;
  final DateTime generatedAt;

  const DailyBriefing({required this.content, required this.generatedAt});

  Map<String, dynamic> toJson() => {
        'content': content,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory DailyBriefing.fromJson(Map<dynamic, dynamic> json) => DailyBriefing(
        content: json['content'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}
