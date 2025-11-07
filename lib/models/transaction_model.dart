class Transaction {
  final int id;
  final int menuId;
  final int quantity;
  final double totalPrice;
  final String paymentMethod;
  final String createdAt;

  Transaction({
    required this.id,
    required this.menuId,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      menuId: json['menu_id'] ?? json['menuId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      totalPrice: ((json['total_price'] ?? json['totalPrice'] ?? 0) as num).toDouble(),
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'quantity': quantity,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'created_at': createdAt,
    };
  }
}
