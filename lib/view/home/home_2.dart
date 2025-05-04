// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/providers/product_provider.dart';
import 'package:spark_aquanix/backend/providers/products_provider.dart';
import 'package:spark_aquanix/view/home/widgets/product_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchProducts();
      productProvider.fetchFeaturedProducts();
      productProvider.fetchDiscountedProducts();
      productProvider.fetchCategories();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop App'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (ctx) => const SearchScreen(),
          //       ),
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.shopping_cart),
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (ctx) => const CartScreen(),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);
          productProvider.fetchProducts();
          productProvider.fetchFeaturedProducts();
          productProvider.fetchDiscountedProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Featured Products Carousel
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // const FeaturedProductsCarousel(),
              const SizedBox(height: 16),

              // Categories
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // const CategoryList(),
              const SizedBox(height: 16),

              // Products Grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'All Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Consumer<ProductProvider>(
                builder: (ctx, productProvider, _) {
                  if (productProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (productProvider.products.isEmpty) {
                    return const Center(
                      child: Text('No products found'),
                    );
                  }

                  return ProductGrid(products: productProvider.products);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
