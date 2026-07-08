import 'package:equatable/equatable.dart';

class WikiEntry extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final List<String> keywords;
  final String imageUrl;
  final DateTime lastUpdated;
  final String category;
  final List<String> relatedTopics;
  final int readCount;
  final double relevanceScore;

  const WikiEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.keywords,
    required this.imageUrl,
    required this.lastUpdated,
    required this.category,
    this.relatedTopics = const [],
    this.readCount = 0,
    this.relevanceScore = 0.0,
  });

  WikiEntry copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    List<String>? keywords,
    String? imageUrl,
    DateTime? lastUpdated,
    String? category,
    List<String>? relatedTopics,
    int? readCount,
    double? relevanceScore,
  }) {
    return WikiEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      keywords: keywords ?? this.keywords,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
      relatedTopics: relatedTopics ?? this.relatedTopics,
      readCount: readCount ?? this.readCount,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        keywords,
        imageUrl,
        lastUpdated,
        category,
        relatedTopics,
        readCount,
        relevanceScore,
      ];
}
