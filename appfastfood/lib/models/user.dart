class User {
  final int userId;
  final String fullname;
  final String email;
  final String phone;
  final String? birthday;
  final String? image;

  User({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.phone,
    this.birthday,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      birthday: json['BirthDay'] ?? json['birthday'], 
      image: json['Image'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'birthday': birthday,
      'image': image,
    };
  }
}