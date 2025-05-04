import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/providers/product_provider.dart';
import 'package:spark_aquanix/view/home/widgets/product_grid.dart';
import 'package:spark_aquanix/view/home/widgets/whats_app_chat.dart';
import 'package:spark_aquanix/view/products/widgets/image_carousel.dart';

import 'widgets/carousel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        productProvider.fetchProducts();
        productProvider.fetchFeaturedProducts();
        productProvider.fetchDiscountedProducts();
        productProvider.fetchCategories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
          ],
        ),
        floatingActionButton: const WhatsAppButton(),
        body: RefreshIndicator(
          onRefresh: () async {
            final productProvider =
                Provider.of<ProductProvider>(context, listen: false);
            productProvider.fetchProducts();
            productProvider.fetchFeaturedProducts();
            productProvider.fetchDiscountedProducts();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 16),

                      CarouselScreen(),
                      SizedBox(height: 16),

                      // Categories header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Categories list
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: Consumer<ProductProvider>(
                    builder: (ctx, productProvider, _) {
                      final categories = productProvider.categories;
                      if (productProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              categories[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 16),
              ),

              // All Products header
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 8),
              ),

              // Product grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<ProductProvider>(
                    builder: (ctx, productProvider, _) {
                      if (productProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (productProvider.products.isEmpty) {
                        return const Center(child: Text('No products found'));
                      }
                      return ProductGrid(products: productProvider.products);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
