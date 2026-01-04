import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập các đơn hàng lịch sử (Đã Việt hóa)
    final List<Map<String, dynamic>> historyOrders = [
      {
        "orderNo": "0054752",
        "date": "29 Th11, 13:20",
        "status": "Giao hàng thành công",
        "price": "50.000",
        "items": 2,
        "highlight": true, // Nút Chi tiết màu đậm
      },
      {
        "orderNo": "0028762",
        "date": "10 Th11, 18:05",
        "status": "Giao hàng thành công",
        "price": "50.000",
        "items": 2,
        "highlight": false, // Nút Chi tiết màu nhạt
      },
      {
        "orderNo": "0881990",
        "date": "10 Th11, 08:30",
        "status": "Giao hàng thành công",
        "price": "8.000",
        "items": 1,
        "highlight": false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCD057), // Màu vàng header
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        // Giữ nút back nếu muốn, hoặc bỏ đi nếu là màn hình chính trong tab
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFFE95322)),
          onPressed: () {
            // Navigator.pop(context); // Mở comment nếu muốn nút back hoạt động
          },
        ),
        title: const Text(
          "Lịch Sử Đặt Hàng",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: historyOrders.length,
        separatorBuilder: (context, index) => const Divider(height: 40, thickness: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          final order = historyOrders[index];
          return _buildHistoryItem(order);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột bên trái: Mã đơn, Ngày, Trạng thái
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mã đơn: ${order['orderNo']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order['date'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFFE95322)),
                    const SizedBox(width: 5),
                    Text(
                      order['status'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE95322), // Màu cam cho trạng thái
                      ),
                    ),
                  ],
                )
              ],
            ),

            // Cột bên phải: Giá, Số lượng item, Nút Chi tiết
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${order['price']}đ",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE95322),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${order['items']} món",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                
                // Nút Chi tiết (Details)
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: order['highlight'] == true 
                          ? const Color(0xFFE95322) // Cam đậm
                          : const Color(0xFFFFCCBC), // Cam nhạt
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      "Chi tiết",
                      style: TextStyle(
                        fontSize: 12,
                        color: order['highlight'] == true 
                            ? Colors.white 
                            : const Color(0xFFE95322),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}