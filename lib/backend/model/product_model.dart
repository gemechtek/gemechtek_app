class Product {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.isFavorite = false,
  });

  // Convert Product to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  // Create Product from Map (for fetching from database/API)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      rating: map['rating'],
      imageUrl: map['imageUrl'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // Create a copy of Product with modified properties
  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? rating,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
