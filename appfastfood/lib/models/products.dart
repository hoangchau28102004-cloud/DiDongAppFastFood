class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryName,
  });

  // Hàm chuyển từ JSON sang Object Dart
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? 0, // Map với key 'product_id' trong JSON
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // Chuyển chuỗi "55000.00" thành số thực double
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      categoryName: json['category_name'] ?? '',
    );
  }
}
