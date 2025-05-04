enum PaymentType {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  upi,
  all;

  @override
  String toString() {
    return switch (this) {
      PaymentType.cash => 'Cash',
      PaymentType.creditCard => 'Credit Card',
      PaymentType.debitCard => 'Debit Card',
      PaymentType.bankTransfer => 'Bank Transfer',
      PaymentType.upi => 'UPI',
      PaymentType.all => 'All',
    };
  }

  String get value => toString();

  static PaymentType fromString(String value) {
    return switch (value) {
      'Cash' => PaymentType.cash,
      'Credit Card' => PaymentType.creditCard,
      'Debit Card' => PaymentType.debitCard,
      'Bank Transfer' => PaymentType.bankTransfer,
      'UPI' => PaymentType.upi,
      'All' => PaymentType.all,
      _ => PaymentType.cash,
    };
  }
}
