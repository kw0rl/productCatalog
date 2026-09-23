import 'package:flutter_test/flutter_test.dart';
import 'package:productcatalog/product_model/product.dart';

void main() {
  test('converts integer price and rating to double', () {
    //arrange
    final Map<String, dynamic> sampleDummyJson = {
      'id': 1,
      'title': 'Test Phone',
      'price': 1000, // integer price
      'thumbnail': 'https://example.com/thumbnail.jpg',
      'description': 'A test phone',
      'rating': 4, // integer rating
      'images': ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
    };

    //act
    final product = Product.fromJson(sampleDummyJson);

    //assert
    //1. check if the price and rating are converted to double
    expect(product.price, isA<double>());
    expect(product.rating, isA<double>());

    //2. check value if the price and rating are correct
    expect(product.price, 1000.0);
    expect(product.rating, 4.0);
    expect(product.title, 'Test Phone');
  });
}
