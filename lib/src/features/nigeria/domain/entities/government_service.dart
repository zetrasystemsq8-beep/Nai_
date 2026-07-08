import 'package:equatable/equatable.dart';

class GovernmentService extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconUrl;
  final String website;
  final String? phoneNumber;
  final String? email;
  final String location;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final bool isVerified;

  const GovernmentService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconUrl,
    required this.website,
    this.phoneNumber,
    this.email,
    required this.location,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.tags = const [],
    this.isVerified = false,
  });

  GovernmentService copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? iconUrl,
    String? website,
    String? phoneNumber,
    String? email,
    String? location,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    bool? isVerified,
  }) {
    return GovernmentService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        iconUrl,
        website,
        phoneNumber,
        email,
        location,
        rating,
        reviewCount,
        tags,
        isVerified,
      ];
}
