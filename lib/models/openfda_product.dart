
class OpenFdaProduct {
  final String productNdc;
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String dosageForm;
  final String productType;
  final List<String> routes;
  final List<String> activeIngredients;

  const OpenFdaProduct({
    required this.productNdc,
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.dosageForm,
    required this.productType,
    required this.routes,
    required this.activeIngredients,
  });

  factory OpenFdaProduct.fromJson(Map<String, dynamic> json) {
    final ingredients = json['active_ingredients'];

    return OpenFdaProduct(
      productNdc: json['product_ndc'] ?? '',
      genericName: json['generic_name'] ?? '',
      brandName: json['brand_name'] ?? '',
      manufacturer: json['labeler_name'] ?? '',
      dosageForm: json['dosage_form'] ?? '',
      productType: json['product_type'] ?? '',
      routes: json['route'] is List
          ? List<String>.from(json['route'])
          : [],
      activeIngredients: ingredients is List
          ? ingredients
              .whereType<Map<String, dynamic>>()
              .map((item) => item['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList()
          : [],
    );
  }
}
