
class Medicine {
  final int? id;
  final String name;
  final String category;
  final String description;
  final String packaging;
  final int stock;
  final DateTime? createdAt;

  const Medicine({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.packaging,
    required this.stock,
    this.createdAt,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      packaging: json['packaging'] as String,
      stock: json['stock'] as int,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'packaging': packaging,
      'stock': stock,
    };
  }
}
