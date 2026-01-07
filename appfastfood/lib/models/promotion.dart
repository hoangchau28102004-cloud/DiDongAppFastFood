class Promotion {
  final int id;
  final String name;
  final double discountPercent; 
  final DateTime? startDate;
  final DateTime? endDate;
  final int status;

  Promotion({
    required this.id,
    required this.name,
    required this.discountPercent,
    this.startDate,
    this.endDate,
    required this.status,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: int.tryParse(json['promotion_id'].toString()) ?? 0,
      name: json['name'] ?? "Khuyến mãi",
      
      // Xử lý số liệu decimal/double
      discountPercent: double.tryParse(json['discount_percent'].toString()) ?? 0.0,
      
      // Xử lý ngày tháng (backend trả về String dạng '2025-02-02 00:00:00')
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      
      status: int.tryParse(json['status'].toString()) ?? 0,
    );
  }
}