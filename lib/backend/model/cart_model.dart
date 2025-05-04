// models/cart_model.dart
import 'package:spark_aquanix/constants/enums/product_color.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String image;
  final ProductColor selectedColor;
  final String size;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image,
    required this.selectedColor,
    required this.size,
  });

  // Total price for this cart item
  double get totalPrice => price * quantity;

  // Create a copy of this cart item with updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
      selectedColor: selectedColor,
      size: size,
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
    );
  }
}
