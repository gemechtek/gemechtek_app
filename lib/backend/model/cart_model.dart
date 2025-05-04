import 'package:spark_aquanix/constants/enums/payment_type.dart';
import 'package:spark_aquanix/constants/enums/product_color.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String image;
  final ProductColor selectedColor;
  final String size;
  final List<PaymentType> paymentTypes;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image,
    required this.selectedColor,
    required this.size,
    required this.paymentTypes,
  });

  // Total price for this cart item
  double get totalPrice => price * quantity;

  // Create a copy of this cart item with updated quantity
  CartItem copyWith({
    int? quantity,
    List<PaymentType>? paymentTypes,
  }) {
    return CartItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
      selectedColor: selectedColor,
      size: size,
      paymentTypes: paymentTypes ?? this.paymentTypes,
    );
  }

  // Convert cart item to a Map for storing
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
      'selectedColor': selectedColor.toString(),
      'size': size,
      'paymentTypes': paymentTypes.map((type) => type.toString()).toList(),
    };
  }

  // Create a cart item from a Map (for retrieving from storage)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      image: map['image'] ?? '',
      selectedColor: ProductColor.fromString(map['selectedColor'] ?? 'Blue'),
      size: map['size'] ?? '',
      paymentTypes: (map['paymentTypes'] as List<dynamic>?)
              ?.map((type) => PaymentType.values.firstWhere(
                  (e) => e.toString() == type,
                  orElse: () => PaymentType.cash))
              .toList() ??
          [],
    );
  }
}
