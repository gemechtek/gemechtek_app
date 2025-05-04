import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spark_aquanix/backend/model/User_Product.dart';

class ProductService {
  final CollectionReference _productsCollection;
  final CollectionReference _categoriesCollection;

  ProductService()
      : _productsCollection = FirebaseFirestore.instance.collection('products'),
        _categoriesCollection =
            FirebaseFirestore.instance.collection('categories');

  Stream<List<UserProduct>> getProducts() {
    return _productsCollection
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserProduct.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<UserProduct>> getProductsByCategory(String category) {
    return _productsCollection
        .where('status', isEqualTo: 'Active')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserProduct.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<UserProduct?> getProductById(String productId) async {
    DocumentSnapshot doc = await _productsCollection.doc(productId).get();
    if (doc.exists) {
      return UserProduct.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<List<String>> getCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();
    });
  }

  Stream<List<UserProduct>> searchProducts(String query) {
    return _productsCollection
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            return UserProduct.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id);
          })
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Stream<List<UserProduct>> getFeaturedProducts() {
    return _productsCollection
        .where('status', isEqualTo: 'Active')
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

  Stream<List<UserProduct>> getDiscountedProducts() {
    return _productsCollection
        .where('status', isEqualTo: 'Active')
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
