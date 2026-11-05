
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/openfda_product.dart';

class OpenFdaService {
  static const String _baseUrl =
      'https://api.fda.gov/drug/ndc.json';

  Future<List<OpenFdaProduct>> getProducts() async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'search': 'product_type:"HUMAN OTC DRUG"',
        'limit': '20',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> results =
          data['results'] as List<dynamic>;

      return results
          .map(
            (item) => OpenFdaProduct.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Gagal mengambil data OpenFDA. '
      'Status code: ${response.statusCode}',
    );
  }
}
