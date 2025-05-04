enum ProductStatus {
  active,
  inactive,
  outOfStock,
  comingSoon,
  discontinued;

  @override
  String toString() {
    return switch (this) {
      ProductStatus.active => 'Active',
      ProductStatus.inactive => 'Inactive',
      ProductStatus.outOfStock => 'Out Of Stock',
      ProductStatus.comingSoon => 'Coming Soon',
      ProductStatus.discontinued => 'Discontinued',
    };
  }

  String get value => toString();

  static ProductStatus fromString(String value) {
    return switch (value) {
      'Active' => ProductStatus.active,
      'Inactive' => ProductStatus.inactive,
      'Out Of Stock' => ProductStatus.outOfStock,
      'Coming Soon' => ProductStatus.comingSoon,
      'Discontinued' => ProductStatus.discontinued,
      _ => ProductStatus.active,
    };
  }
}
