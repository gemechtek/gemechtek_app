import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark_aquanix/backend/model/cart_model.dart';
import 'package:spark_aquanix/constants/enums/payment_type.dart';
import 'package:spark_aquanix/constants/enums/product_color.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isInitialized = false;

  CartProvider() {
    // Load cart data when provider is created
    loadCart();
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Get the total quantity of all items in the cart
  int get totalItemQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get the quantity of a specific product in the cart
  int getQuantity(String productId, ProductColor color, String size) {
    final index = _items.indexWhere((item) =>
        item.productId == productId &&
        item.selectedColor == color &&
        item.size == size);

    if (index != -1) {
      return _items[index].quantity;
    }
    return 0;
  }

  // Add a product to the cart
  void addItem({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required String image,
    required ProductColor selectedColor,
    required String size,
    required List<PaymentType> paymentTypes,
  }) {
    final index = _items.indexWhere((item) =>
        item.productId == productId &&
        item.selectedColor == selectedColor &&
        item.size == size);

    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          productId: productId,
          productName: productName,
          price: price,
          quantity: quantity,
          image: image,
          selectedColor: selectedColor,
          size: size,
          paymentTypes: paymentTypes,
        ),
      );
    }

    _saveToPrefs();
    notifyListeners();
  }

  // Remove an item from the cart
  void removeItem(String productId, ProductColor color, String size) {
    _items.removeWhere((item) =>
        item.productId == productId &&
        item.selectedColor == color &&
        item.size == size);

    _saveToPrefs();
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(
      String productId, ProductColor color, String size, int quantity) {
    if (quantity <= 0) {
      removeItem(productId, color, size);
      return;
    }

    final index = _items.indexWhere((item) =>
        item.productId == productId &&
        item.selectedColor == color &&
        item.size == size);

    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // Clear the cart
  void clear() {
    _items = [];
    _saveToPrefs();
    notifyListeners();
  }

  // Save cart to shared preferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = json.encode(
        _items.map((item) => item.toMap()).toList(),
      );
      await prefs.setString('cart', cartData);
      if (kDebugMode) {
        print('Cart saved to SharedPreferences: $cartData');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart to SharedPreferences: $e');
      }
    }
  }

  // Load cart from shared preferences
  Future<void> loadCart() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');

      if (kDebugMode) {
        print('Loading cart from SharedPreferences: $cartData');
      }

      if (cartData != null && cartData.isNotEmpty) {
        final List<dynamic> decodedData = json.decode(cartData);
        _items = decodedData.map((item) => CartItem.fromMap(item)).toList();
        notifyListeners();
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart from SharedPreferences: $e');
      }
      _isInitialized = true;
    }
  }

  // For debugging - verify if the cart is properly loaded
  bool get isLoaded => _isInitialized;
}
