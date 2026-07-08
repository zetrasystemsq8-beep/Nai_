import 'package:equatable/equatable.dart';

class NewsArticle extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;
  final String category;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.category,
  });

  @override
  List<Object?> get props => [id, title, description, content, imageUrl, source, publishedAt, category];
}
