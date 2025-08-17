import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark_aquanix/backend/firebase_services/product_service.dart';
import 'package:spark_aquanix/backend/model/cart_model.dart';
import 'package:spark_aquanix/backend/model/user_product.dart';
import 'package:spark_aquanix/constants/enums/payment_type.dart';
import 'package:spark_aquanix/constants/enums/product_color.dart';
import 'package:spark_aquanix/constants/enums/product_status.dart';
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

  // Load cart from shared preferences and update with Firestore data
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

        // Update cart items with latest data from Firestore
        await _updateCartItemsFromFirestore();

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

  // Update cart items with latest data from Firestore
  Future<void> _updateCartItemsFromFirestore() async {
    final productService = ProductService();
    List<CartItem> updatedItems = [];
    bool hasChanges = false;

    for (var item in _items) {
      try {
        final product = await productService.getProductById(item.productId);

        if (product != null) {
          // Check if product is still available
          if (product.status == ProductStatus.active && product.stock > 0) {
            // Update cart item with latest product data
            final updatedItem = item.copyWith(
              productName: product.name,
              price: product.finalPrice,
              image: product.images.isNotEmpty ? product.images.first : '',
              paymentTypes: product.paymentTypes,
            );

            // If the product details have changed, mark that we need to save
            if (updatedItem.price != item.price ||
                updatedItem.productName != item.productName ||
                updatedItem.image != item.image ||
                !_arePaymentTypesEqual(
                    updatedItem.paymentTypes, item.paymentTypes)) {
              hasChanges = true;
            }

            updatedItems.add(updatedItem);
          } else {
            // Product is no longer available
            hasChanges = true;
            if (kDebugMode) {
              print(
                  'Removing unavailable product from cart: ${item.productId}');
            }
          }
        } else {
          // Product no longer exists
          hasChanges = true;
          if (kDebugMode) {
            print('Removing non-existent product from cart: ${item.productId}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating cart item ${item.productId}: $e');
        }
        // Keep the original item if there's an error
        updatedItems.add(item);
      }
    }

    // Update the cart if there were any changes
    if (hasChanges) {
      _items = updatedItems;
      await _saveToPrefs();
    }
  }

  // Helper method to compare payment types lists
  bool _arePaymentTypesEqual(List<PaymentType> list1, List<PaymentType> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // For debugging - verify if the cart is properly loaded
  bool get isLoaded => _isInitialized;
}
