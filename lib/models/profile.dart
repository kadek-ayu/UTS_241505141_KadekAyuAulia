
class Profile {
  final int id;
  final String customerId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;

  const Profile({
    required this.id,
    required this.customerId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as int,
      customerId: map['customer_id'] ?? '',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      email: map['email'],
      address: map['address'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      avatarUrl: map['avatar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
    };
  }
}
