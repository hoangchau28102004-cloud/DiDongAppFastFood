import 'package:appfastfood/models/reviews.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryName;
  final double? averageRating;
  final int? reviewCount;
  final List<Reviews> review;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryName,
    this.averageRating,
    this.reviewCount,
    this.review = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // JSON trả về String "55000.00" nên cần parse
      price: double.tryParse(json['price'].toString()) ?? 0,
      imageUrl: json['image_url'] ?? '',
      averageRating: double.tryParse(json['average_rating'].toString()) ?? 0.0,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
      categoryName: json['category_name'] ?? '',
      review:
          (json['reviews'] as List?)
              ?.map((item) => Reviews.fromJson(item))
              .toList() ??
          [],
    );
  }
}
