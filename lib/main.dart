import 'package:flutter/material.dart';
import 'package:productcatalog/product_model/product.dart';
import 'package:productcatalog/services/product_service.dart';

void main() => runApp(const ProductCatalogApp());

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const CatalogScreen(),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ProductService _productService = ProductService();
  final List<Product> _products = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 300) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore) {
      return;
    }
    //ambil data akan tambah di sini
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset error message before fetching new data
    });

    try {
      //fetch data and manage success result
      final newProducts = await _productService.fetchProducts(
        skip: _products.length,
      );
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        _products.addAll(newProducts);
        _hasMore = newProducts.length == 20; // Assuming if the API returns less than 20 products, there are no more products to load
      });
    } catch (error) {
      //manage error result
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        _errorMessage = 'Failed to load products. Please try again.';
      });
    } finally {
      //end loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBody() {
    //logic to choose what to display based on the state of the app
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load products. Please try again.'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Retry fetching products
                _loadProducts();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    final products = _products;
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        
        if (_errorMessage != null && !_isLoading)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Retry fetching products
                _loadProducts();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body: _buildBody(),
    );
  }
}
