import 'package:flutter/material.dart';
import 'package:productcatalog/product_model/product.dart';
import 'package:productcatalog/services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  late Future<Product> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = _productService.fetchProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: FutureBuilder<Product>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load product.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureProduct = _productService.fetchProductById(
                          widget.productId,
                        );
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Product not found.'));
          }

          final product = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final imageUrl in product.images)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                              ),
                            ),
                            );
                        },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                      ),
                    ),
                  Text(product.title),
                  const SizedBox(height: 8),
                  Text('\$${product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text(product.description),
                  const SizedBox(height: 8),
                  Text('Rating: ${product.rating}'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
