import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:productcatalog/product_model/product.dart';

class ProductService {
  Future<List<Product>> fetchProducts({
    int skip = 0,
    int limit = 20,
    String query = '',
  }) async {
    final searchQuery = query.trim();

    final uri = Uri.https(
      'dummyjson.com',
      searchQuery.isEmpty ? '/products' : '/products/search',
      {
        'limit': '$limit',
        'skip': '$skip',
        if (searchQuery.isNotEmpty) 'q': searchQuery,
      },
    );
    
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> fetchProductById(int id) async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/$id'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product with id $id');
    }
  }
}
