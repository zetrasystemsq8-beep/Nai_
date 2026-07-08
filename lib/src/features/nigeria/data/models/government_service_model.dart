import 'package:nai/src/features/nigeria/domain/entities/government_service.dart';

class GovernmentServiceModel extends GovernmentService {
  const GovernmentServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.iconUrl,
    required super.website,
    super.phoneNumber,
    super.email,
    required super.location,
    super.rating = 4.5,
    super.reviewCount = 0,
    super.tags = const [],
    super.isVerified = false,
  });

  factory GovernmentServiceModel.fromJson(Map<String, dynamic> json) {
    return GovernmentServiceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      website: json['website'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      location: json['location'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'iconUrl': iconUrl,
        'website': website,
        'phoneNumber': phoneNumber,
        'email': email,
        'location': location,
        'rating': rating,
        'reviewCount': reviewCount,
        'tags': tags,
        'isVerified': isVerified,
      };
}
