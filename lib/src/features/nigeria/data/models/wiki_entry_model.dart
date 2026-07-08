import 'package:nai/src/features/nigeria/domain/entities/wiki_entry.dart';

class WikiEntryModel extends WikiEntry {
  const WikiEntryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.keywords,
    required super.imageUrl,
    required super.lastUpdated,
    required super.category,
    super.relatedTopics = const [],
    super.readCount = 0,
    super.relevanceScore = 0.0,
  });

  factory WikiEntryModel.fromJson(Map<String, dynamic> json) {
    return WikiEntryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      keywords: List<String>.from(json['keywords'] as List? ?? []),
      imageUrl: json['imageUrl'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      category: json['category'] as String? ?? '',
      relatedTopics: List<String>.from(json['relatedTopics'] as List? ?? []),
      readCount: json['readCount'] as int? ?? 0,
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'content': content,
        'keywords': keywords,
        'imageUrl': imageUrl,
        'lastUpdated': lastUpdated.toIso8601String(),
        'category': category,
        'relatedTopics': relatedTopics,
        'readCount': readCount,
        'relevanceScore': relevanceScore,
      };
}
