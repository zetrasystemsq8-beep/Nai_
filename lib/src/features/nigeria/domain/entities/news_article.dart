import 'package:equatable/equatable.dart';

class NewsArticle extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String source;
  final String imageUrl;
  final DateTime publishedAt;
  final String category;
  final int views;
  final bool isBookmarked;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.category,
    this.views = 0,
    this.isBookmarked = false,
  });

  NewsArticle copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? source,
    String? imageUrl,
    DateTime? publishedAt,
    String? category,
    int? views,
    bool? isBookmarked,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      views: views ?? this.views,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        source,
        imageUrl,
        publishedAt,
        category,
        views,
        isBookmarked,
      ];
}
