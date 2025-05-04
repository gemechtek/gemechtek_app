// screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spark_aquanix/backend/model/User_Product.dart';
import 'package:spark_aquanix/backend/providers/cart_provider.dart';
import 'package:spark_aquanix/backend/providers/product_provider.dart';
import 'package:spark_aquanix/constants/enums/product_color.dart';
import 'package:spark_aquanix/navigation/navigator_helper.dart';
import 'package:spark_aquanix/view/cart/cart_screen.dart';
import 'package:spark_aquanix/view/products/widgets/image_carousel.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<UserProduct?> _productFuture;
  int _quantity = 1;
  ProductColor _selectedColor = ProductColor.blue;

  @override
  void initState() {
    super.initState();
    _productFuture = Provider.of<ProductProvider>(context, listen: false)
        .getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Consumer<CartProvider>(
            builder: (ctx, cartProvider, _) => Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (ctx) => const CartScreen(),
                    //   ),
                    // );
                    NavigationHelper.navigateToCart(context);
                  },
                ),
                if (cartProvider.totalItemQuantity > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartProvider.totalItemQuantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<UserProduct?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Product not found'));
          }

          final product = snapshot.data!;

          // Set initial selected color
          if (product.colors.isNotEmpty &&
              _selectedColor == ProductColor.blue) {
            _selectedColor = product.colors.first;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                ImageCarousel(images: product.images),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          Text(
                            '₹${product.finalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (product.discountPercentage > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹${product.basePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.discountType == 'Percentage'
                                    ? '${product.discountPercentage.toStringAsFixed(0)}% OFF'
                                    : '₹${product.discountPercentage.toStringAsFixed(0)} OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stock
                      Row(
                        children: [
                          const Text(
                            'Availability: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product.stock > 0
                                ? 'In Stock (${product.stock})'
                                : 'Out of Stock',
                            style: TextStyle(
                              color:
                                  product.stock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Colors
                      if (product.colors.isNotEmpty) ...[
                        const Text(
                          'Colors:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: product.colors.length,
                            itemBuilder: (ctx, i) {
                              final color = product.colors[i];
                              final isSelected = color == _selectedColor;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = color;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: ProductColor.getColorForEnum(color),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Size
                      Row(
                        children: [
                          const Text(
                            'Size: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(product.size),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      Row(
                        children: [
                          const Text(
                            'Quantity: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            _quantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _quantity < product.stock
                                ? () {
                                    setState(() {
                                      _quantity++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),

                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.stock > 0
                              ? () {
                                  final cartProvider =
                                      Provider.of<CartProvider>(
                                    context,
                                    listen: false,
                                  );
                                  cartProvider.addItem(
                                    productId: product.id,
                                    productName: product.name,
                                    price: product.finalPrice,
                                    quantity: _quantity,
                                    image: product.images[0],
                                    selectedColor: _selectedColor,
                                    size: product.size,
                                  );
                                  // cartProvider.addItem(
                                  //   product,
                                  //   _quantity,
                                  //   _selectedColor,
                                  // );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Added to cart'),
                                      action: SnackBarAction(
                                        label: 'View Cart',
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (ctx) =>
                                                  const CartScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
