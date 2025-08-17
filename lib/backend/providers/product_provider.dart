import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark_aquanix/backend/firebase_services/product_service.dart';
import 'package:spark_aquanix/backend/model/user_product.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<UserProduct> _products = [];
  List<UserProduct> _featuredProducts = [];
  List<UserProduct> _discountedProducts = [];
  List<UserProduct> _searchResults = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _selectedCategory = '';
  String _searchQuery = '';

  List<UserProduct> get products =>
      _searchQuery.isEmpty ? _products : _searchResults;
  List<UserProduct> get featuredProducts => _featuredProducts;
  List<UserProduct> get discountedProducts => _discountedProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<String> _favoriteProductIds = [];
  List<String> get favoriteProducts => _favoriteProductIds;

  Future<void> loadFavoriteProducts() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteProductIds = prefs.getStringList('favoriteIds') ?? [];
    notifyListeners();
  }

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

  // Search products by name or category
  void searchProducts(String query) {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _productService.searchProducts(query).listen((productsList) {
      _searchResults = productsList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Get a single product by ID
  Future<UserProduct?> getProductById(String productId) {
    return _productService.getProductById(productId);
  }
}
