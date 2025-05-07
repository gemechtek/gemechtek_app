// models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spark_aquanix/constants/enums/order_status.dart';
import 'package:spark_aquanix/constants/enums/payment_type.dart';
import 'package:spark_aquanix/constants/enums/product_color.dart';
import 'cart_model.dart';

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String image;
  final ProductColor selectedColor;
  final String size;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image,
    required this.selectedColor,
    required this.size,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
      'selectedColor': selectedColor.toString(),
      'size': size,
    };
  }

  // Create from CartItem
  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.productId,
      productName: cartItem.productName,
      price: cartItem.price,
      quantity: cartItem.quantity,
      image: cartItem.image,
      selectedColor: cartItem.selectedColor,
      size: cartItem.size,
    );
  }

  // Create from Firestore Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      image: map['image'] ?? '',
      selectedColor: ProductColor.fromString(map['selectedColor'] ?? 'Blue'),
      size: map['size'] ?? '',
    );
  }
}

class DeliveryAddress {
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  DeliveryAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
    );
  }
}

class OrderDetails {
  final String? id;
  final String userId;
  final String userName; // Added user name field
  final String userFcmToken; // Added FCM token field
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final DeliveryAddress deliveryAddress;
  final PaymentType paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDetails({
    this.id,
    required this.userId,
    required this.userName, // Added user name parameter
    required this.userFcmToken, // Added FCM token parameter
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userFcmToken': userFcmToken,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shippingCost': shippingCost,
      'total': total,
      'deliveryAddress': deliveryAddress.toMap(),
      'paymentMethod': paymentMethod.toString(),
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory OrderDetails.fromFirestore(Map<String, dynamic> data, String docId) {
    return OrderDetails(
      id: docId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userFcmToken: data['userFcmToken'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      shippingCost: (data['shippingCost'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      deliveryAddress: DeliveryAddress.fromMap(
          data['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      paymentMethod: PaymentType.fromString(data['paymentMethod'] ?? 'Cash'),
      status: OrderStatus.fromString(data['status'] ?? 'Pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  OrderDetails copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userFcmToken,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? total,
    DeliveryAddress? deliveryAddress,
    PaymentType? paymentMethod,
    OrderStatus? status,
    DateTime? updatedAt,
  }) {
    return OrderDetails(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userFcmToken: userFcmToken ?? this.userFcmToken,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
