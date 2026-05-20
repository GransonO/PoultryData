class UserModel {
  final String name;
  final String phone;
  final String email;
  final DateTime registeredAt;

  const UserModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.registeredAt,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    DateTime? registeredAt,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'registeredAt': registeredAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        registeredAt: DateTime.parse(json['registeredAt'] as String),
      );

  String get firstName => name.split(' ').first;
}
