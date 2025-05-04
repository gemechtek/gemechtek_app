enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  @override
  String toString() {
    return switch (this) {
      OrderStatus.pending => 'Pending',
      OrderStatus.processing => 'Processing',
      OrderStatus.shipped => 'Shipped',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };
  }

  String get value => toString();

  static OrderStatus fromString(String value) {
    return switch (value) {
      'Pending' => OrderStatus.pending,
      'Processing' => OrderStatus.processing,
      'Shipped' => OrderStatus.shipped,
      'Delivered' => OrderStatus.delivered,
      'Cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.pending,
    };
  }
}
