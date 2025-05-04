// providers/product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:spark_aquanix/backend/firebase_services/product_service.dart';
import 'package:spark_aquanix/backend/model/User_Product.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<UserProduct> _products = [];
  List<UserProduct> _featuredProducts = [];
  List<UserProduct> _discountedProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _selectedCategory = '';

  List<UserProduct> get products => _products;
  List<UserProduct> get featuredProducts => _featuredProducts;
  List<UserProduct> get discountedProducts => _discountedProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  ProductProvider() {
    fetchProducts();
    fetchFeaturedProducts();
    fetchDiscountedProducts();
    fetchCategories();
  }

  // Set up streams to listen for product updates
  void fetchProducts() {
    _isLoading = true;
    notifyListeners();

    _productService.getProducts().listen((productsList) {
      _products = productsList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Fetch products by category
  void fetchProductsByCategory(String category) {
    _isLoading = true;
    _selectedCategory = category;
    notifyListeners();

    if (category.isEmpty) {
      fetchProducts();
      return;
    }

    _productService.getProductsByCategory(category).listen((productsList) {
      _products = productsList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Fetch featured products
  void fetchFeaturedProducts() {
    _productService.getFeaturedProducts().listen((productsList) {
      _featuredProducts = productsList;
      notifyListeners();
    });
  }

  // Fetch discounted products
  void fetchDiscountedProducts() {
    _productService.getDiscountedProducts().listen((productsList) {
      _discountedProducts = productsList;
      notifyListeners();
    });
  }

  // Fetch all categories
  void fetchCategories() {
    _productService.getCategories().listen((categoriesList) {
      _categories = categoriesList;
      notifyListeners();
    });
  }

  // Search products
  void searchProducts(String query) {
    _isLoading = true;
    notifyListeners();

    _productService.searchProducts(query).listen((productsList) {
      _products = productsList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Get a single product by ID
  Future<UserProduct?> getProductById(String productId) {
    return _productService.getProductById(productId);
  }
}
