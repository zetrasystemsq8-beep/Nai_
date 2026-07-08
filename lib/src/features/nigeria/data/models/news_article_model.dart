import 'package:nai/src/features/nigeria/domain/entities/news_article.dart';

class NewsArticleModel extends NewsArticle {
  const NewsArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.content,
    required super.source,
    required super.imageUrl,
    required super.publishedAt,
    required super.category,
    super.views = 0,
    super.isBookmarked = false,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      source: json['source'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : DateTime.now(),
      category: json['category'] as String? ?? '',
      views: json['views'] as int? ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'content': content,
        'source': source,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toIso8601String(),
        'category': category,
        'views': views,
        'isBookmarked': isBookmarked,
      };
}
