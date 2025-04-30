import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/providers/products_provider.dart';
import 'package:spark_aquanix/view/home/widgets/product_grid.dart';
import 'package:spark_aquanix/view/home/widgets/whats_app_chat.dart';

import 'widgets/carousel_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products =
        Provider.of<ProductProvider>(context, listen: false).getMockProducts();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 16),
          ],
        ),
        floatingActionButton: WhatsAppButton(),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Carousel
                    CarouselScreen(),
                    SizedBox(height: 16),

                    // Categories header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        )
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
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: ClampingScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 64,
                          width: 54,
                        ),
                      );
                    }),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // Product grid
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ProductGrid(products: products),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
