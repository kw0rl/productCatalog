import 'package:flutter/material.dart';
import 'package:productcatalog/product_model/product.dart';
import 'package:productcatalog/services/product_service.dart';
import 'package:productcatalog/screens/product_detail_screen.dart';

import 'dart:async';

void main() => runApp(const ProductCatalogApp());

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F7F9),
          foregroundColor: Color(0xFF111827),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
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
  Timer? _debounce;
  String _searchQuery = '';
  int _searchVersion = 0; // Track the version of the search query

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();

      if (!mounted || query == _searchQuery) return;
      setState(() {
        _searchQuery = query;
        _searchVersion++; // Increment the search version
        _products.clear();
        _hasMore = true;
        _isLoading = false;
        _errorMessage = null;
      });
      _loadProducts();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 300) {
      _loadProducts();
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _searchVersion++;
      _products.clear();
      _hasMore = true;
      _isLoading = false;
      _errorMessage = null;
    });
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final requestVersion = _searchVersion; // Capture the current search version
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
        query: _searchQuery,
      );
      if (!mounted || requestVersion != _searchVersion) return;
      setState(() {
        _products.addAll(newProducts);
        _hasMore = newProducts.length == 20; // Assuming if the API returns less than 20 products, there are no more products to load
      });
    } catch (error) {
      //manage error result
      if (!mounted || requestVersion != _searchVersion) return;
      setState(() {
        _errorMessage = 'Failed to load products. Please try again.';
      });
    } finally {
      //end loading state
      if (mounted && requestVersion == _searchVersion) {
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
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load products. Please try again.'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Retry fetching products
                        _loadProducts();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else if (_products.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: const Center(child: Text('No products found.')),
            ),
          );
        },
      );
    }

    final products = _products;
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.80,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.network(
                            product.thumbnail,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: SizedBox(
                          height: 38,
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xD5307038),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Product Catalog',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search Products...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }
}
