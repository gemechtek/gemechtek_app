// providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:spark_aquanix/backend/firebase_services/order_service.dart';
import 'package:spark_aquanix/backend/model/cart_model.dart';
import 'package:spark_aquanix/backend/model/order_model.dart';
import 'package:spark_aquanix/constants/enums/payment_type.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderDetails> _orders = [];
  bool _isLoading = false;

  List<OrderDetails> get orders => _orders;
  bool get isLoading => _isLoading;

  // Fetch user orders
  void fetchUserOrders(String userId) {
    _isLoading = true;
    notifyListeners();

    _orderService.getUserOrders(userId).listen((ordersList) {
      _orders = ordersList;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Place a new order
  Future<String> placeOrder({
    required String userId,
    required String name,
    required String fcm,
    required List<CartItem> cartItems,
    required DeliveryAddress deliveryAddress,
    required PaymentType paymentMethod,
    required double subtotal,
    required double tax,
    required double shippingCost,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Convert cart items to order items
      final orderItems =
          cartItems.map((item) => OrderItem.fromCartItem(item)).toList();

      // Calculate total
      final total = subtotal + tax + shippingCost;

      // Create the order
      final order = OrderDetails(
        userId: userId,
        userName: name,
        userFcmToken: fcm,
        items: orderItems,
        subtotal: subtotal,
        tax: tax,
        shippingCost: shippingCost,
        total: total,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Place the order
      final orderId = await _orderService.placeOrder(order);

      _isLoading = false;
      notifyListeners();

      return orderId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print(e);
      throw Exception('Failed to place order: $e');
    }
  }

  // Get a specific order
  Future<OrderDetails?> getOrderById(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = await _orderService.getOrderById(orderId);

      _isLoading = false;
      notifyListeners();

      return order;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to get order: $e');
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _orderService.cancelOrder(orderId);

      // Update the local orders list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = await _orderService.getOrderById(orderId);
        if (updatedOrder != null) {
          _orders[index] = updatedOrder;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to cancel order: $e');
    }
  }
}
