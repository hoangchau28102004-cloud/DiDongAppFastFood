class CartItem {
  final int cartId;
  final int productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;
  String note;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.note = '',
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'],
      productId: json['product_id'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['image_url'],
      quantity: json['quantity'],
      note: json['note'],
    );
  }
}
