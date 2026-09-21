import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:productcatalog/product_model/product.dart';

class ProductService {
   Future<List<Product>> fetchProducts({
    int skip = 0,
    int limit = 20,
   }) async {
    final response = await http.get(
      Uri.parse ('https://dummyjson.com/products?limit=$limit&skip=$skip')
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}