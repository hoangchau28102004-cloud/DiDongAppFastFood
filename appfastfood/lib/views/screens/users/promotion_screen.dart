import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../../models/promotion.dart';
import '../../../service/api_service.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Promotion>> _promotionFuture;

  @override
  void initState() {
    super.initState();
    _promotionFuture = _apiService.getPromotions(); 
  }

  // Hàm format ngày cho đẹp (VD: 02/02)
  String _formatDate(DateTime? date) {
    if (date == null) return "...";
    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<List<Promotion>>(
        future: _promotionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi kết nối: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có chương trình khuyến mãi nào!"));
          }

          final promotions = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: promotions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = promotions[index];
              
              // Tạo chuỗi hiển thị hạn sử dụng
              String timeDesc = "Hạn dùng: ${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}";
              
              String discountDisplay = item.discountPercent.toStringAsFixed(0);

              return _buildCouponCard(item.name, timeDesc, discountDisplay);
            },
          );
        },
      ),
    );
  }
  Widget _buildCouponCard(String title, String subtitle, String discount) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade100),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title, // Tên chương trình KM từ DB
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle, // Ngày tháng từ DB
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 70, color: Colors.orange.shade200, margin: const EdgeInsets.symmetric(horizontal: 10)),
          
          // Phần Tem đỏ
          SizedBox(
            width: 90,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.785, 
                    child: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(4))),
                  ),
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(4))),
                  Text(
                    "-$discount%", // Số % từ DB
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}