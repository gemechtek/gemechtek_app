import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spark_aquanix/backend/model/user_product.dart';

class ProductService {
  final CollectionReference _productsCollection;
  final CollectionReference _categoriesCollection;

  ProductService()
      : _productsCollection = FirebaseFirestore.instance.collection('products'),
        _categoriesCollection =
            FirebaseFirestore.instance.collection('categories');

  // Get all products (Active and Out Of Stock)
  Stream<List<UserProduct>> getProducts() {
    return _productsCollection
        .where('status', whereIn: ['Active', 'Out Of Stock'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserProduct.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Get products by category (Active and Out Of Stock)
  Stream<List<UserProduct>> getProductsByCategory(String category) {
    return _productsCollection
        .where('category', isEqualTo: category)
        .where('status', whereIn: ['Active', 'Out Of Stock'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserProduct.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Get a specific product by ID
  Future<UserProduct?> getProductById(String productId) async {
    DocumentSnapshot doc = await _productsCollection.doc(productId).get();
    if (doc.exists) {
      return UserProduct.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Get all categories
  Stream<List<String>> getCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();
    });
  }

  // Search products (Active and Out Of Stock)
  Stream<List<UserProduct>> searchProducts(String query) {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            return UserProduct.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id);
          })
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Get featured products (Active and Out Of Stock)
  Stream<List<UserProduct>> getFeaturedProducts() {
    return _productsCollection
        .orderBy('itemSold', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserProduct.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get discounted products (Active and Out Of Stock)
  Stream<List<UserProduct>> getDiscountedProducts() {
    return _productsCollection
        .where('discountPercentage', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserProduct.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
