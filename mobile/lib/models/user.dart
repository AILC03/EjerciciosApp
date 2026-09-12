class User {
  const User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String email;
  final bool isActive;
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
