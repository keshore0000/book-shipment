import 'dart:convert';

import 'package:http/http.dart' as http;

class ShippingApi {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<double> getShippingRate({
    required String courier,
    required String pickup,
    required String delivery,
    required double weight,
  }) async {
    final uri = Uri.parse('$_baseUrl/rates').replace(
      queryParameters: {
        'courier': courier,
        'pickup': Uri.encodeComponent(pickup),
        'delivery': Uri.encodeComponent(delivery),
        'weight': weight.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return double.parse(data['rate'].toString());
    } else {
      throw Exception('Failed to load shipping rate: ${response.statusCode}');
    }
  }
}
