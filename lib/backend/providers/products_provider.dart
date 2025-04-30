import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spark_aquanix/backend/model/product_model.dart';

// Import the Product model
// import 'product_model.dart';

class ProductProvider extends ChangeNotifier {
  // Base URL for your API
  // final String baseUrl;

  // Fetch all products
  // Future<List<Product>> getProducts() async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/products'));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> productJson = json.decode(response.body);
  //       return productJson.map((json) => Product.fromMap(json)).toList();
  //     } else {
  //       throw Exception('Failed to load products: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load products: $e');
  //   }
  // }

  // // Get product details by ID
  // Future<Product> getProductById(String id) async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/products/$id'));

  //     if (response.statusCode == 200) {
  //       return Product.fromMap(json.decode(response.body));
  //     } else {
  //       throw Exception(
  //           'Failed to load product details: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load product details: $e');
  //   }
  // }

  // // Toggle favorite status
  // Future<bool> toggleFavorite(String productId, bool isFavorite) async {
  //   try {
  //     final response = await http.patch(
  //       Uri.parse('$baseUrl/products/$productId/favorite'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({'isFavorite': isFavorite}),
  //     );

  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       throw Exception(
  //           'Failed to update favorite status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to update favorite status: $e');
  //   }
  // }

  // Get mock data (for testing)
  List<Product> getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Circuit Breaker',
        price: 543,
        rating: 4.5,
        imageUrl: 'https://example.com/circuit-breaker.jpg',
      ),
      Product(
        id: '2',
        name: 'Copper Pump',
        price: 543,
        rating: 4.5,
        imageUrl: 'https://example.com/copper-pump.jpg',
      ),
      Product(
        id: '3',
        name: 'Power Switch',
        price: 299,
        rating: 4.3,
        imageUrl: 'https://example.com/power-switch.jpg',
      ),
      Product(
        id: '4',
        name: 'Valve Set',
        price: 427,
        rating: 4.7,
        imageUrl: 'https://example.com/valve-set.jpg',
      ),
      Product(
        id: '1',
        name: 'Circuit Breaker',
        price: 543,
        rating: 4.5,
        imageUrl: 'https://example.com/circuit-breaker.jpg',
      ),
      Product(
        id: '2',
        name: 'Copper Pump',
        price: 543,
        rating: 4.5,
        imageUrl: 'https://example.com/copper-pump.jpg',
      ),
      Product(
        id: '3',
        name: 'Power Switch',
        price: 299,
        rating: 4.3,
        imageUrl: 'https://example.com/power-switch.jpg',
      ),
      Product(
        id: '4',
        name: 'Valve Set',
        price: 427,
        rating: 4.7,
        imageUrl: 'https://example.com/valve-set.jpg',
      ),
    ];
  }
}
