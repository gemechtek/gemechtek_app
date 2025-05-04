import 'package:spark_aquanix/constants/enums/payment_type.dart';
import 'package:spark_aquanix/constants/enums/product_color.dart';
import 'package:spark_aquanix/constants/enums/product_status.dart';

// User-facing product model with only the necessary fields
class UserProduct {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final double discountPercentage;
  final int stock;
  final List<ProductColor> colors;
  final String size;
  final String category;
  final List<String> images;
  final String discountType;
  final List<PaymentType> paymentTypes;
  final ProductStatus status;
  final int itemSold;

  UserProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.discountPercentage,
    required this.stock,
    required this.colors,
    required this.size,
    required this.category,
    required this.images,
    required this.discountType,
    required this.paymentTypes,
    required this.status,
    required this.itemSold,
  });

  // Calculate the final price after discount
  double get finalPrice {
    if (discountType == 'Percentage') {
      return basePrice - (basePrice * discountPercentage / 100);
    } else {
      return basePrice - discountPercentage;
    }
  }

  // Check if the product is available for purchase
  bool get isAvailable => status == ProductStatus.active && stock > 0;

  // Create UserProduct from Firestore document
  factory UserProduct.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserProduct(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      colors: (data['color'] as List<dynamic>?)
              ?.map((c) => ProductColor.fromString(c))
              .toList() ??
          [],
      size: data['size'] ?? '',
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      discountType: data['discountType'] ?? '',
      paymentTypes: (data['paymentType'] as List<dynamic>?)
              ?.map((p) => PaymentType.fromString(p))
              .toList() ??
          [],
      status: ProductStatus.fromString(data['status'] ?? 'active'),
      itemSold: data['itemSold'] ?? 0,
    );
  }
}
