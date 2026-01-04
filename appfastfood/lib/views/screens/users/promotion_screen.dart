import 'package:flutter/material.dart';

class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập
    final List<Map<String, dynamic>> promoProducts = [
      {
        "name": "Mì Ý Bò Bằm",
        "desc": "Món mì kinh điển làm say lòng thực khách...",
        "price": 16.09,
        "oldPrice": 22.99,
        "image":
            "https://images.unsplash.com/photo-1626844131082-256783844137?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        "discount": "-30%",
      },
      {
        "name": "Broccoli Lasagna",
        "desc": "Lorem ipsum dolor sit amet...",
        "price": 12.50,
        "oldPrice": 18.00,
        "image":
            "https://images.unsplash.com/photo-1574837696921-37503dc4581a?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        "discount": "-30%",
      },
      {
        "name": "Gà Rán Mật Ong",
        "desc": "Gà rán giòn tan sốt mật ong...",
        "price": 10.99,
        "oldPrice": 15.99,
        "image":
            "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        "discount": "-30%",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCD057), // Màu vàng header
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Ẩn nút back
        title: const Text(
          "Khuyến Mãi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: promoProducts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = promoProducts[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh + Tem giảm giá
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        item['image'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red, // Tem màu đỏ
                          shape:
                              BoxShape.circle, // Hình tròn hoặc hình răng cưa
                        ),
                        child: Text(
                          item['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE95322),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "${item['price']}đ",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE95322),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${item['oldPrice']}đ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration
                                      .lineThrough, // Gạch ngang giá cũ
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['desc'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}