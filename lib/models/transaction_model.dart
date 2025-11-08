class Transaction {
  final int id;
  final int menuId;
  final int quantity;
  final double totalPrice;
  final String paymentMethod;
  final String createdAt;

  // Optional menu details (dipakai jika API mengirimkan objek menu atau membutuhkan nested menu saat POST)
  final String? menuName;
  final String? menuImage;
  final double? menuPrice;

  Transaction({
    required this.id,
    required this.menuId,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.menuName,
    this.menuImage,
    this.menuPrice,
  });

  // helper parsing
  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString();
    return int.tryParse(s) ?? fallback;
  }

  static double _parseDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s) ?? fallback;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Parse created_at yang bisa dalam berbagai format
    String createdAt = (json['created_at'] ?? json['createdAt'] ?? '')
        .toString();

    // Jika format GMT (dari API), coba convert ke format standar
    if (createdAt.isNotEmpty && createdAt.contains('GMT')) {
      try {
        final dateTime = DateTime.parse(createdAt);
        createdAt =
            '${dateTime.year.toString().padLeft(4, '0')}-'
            '${dateTime.month.toString().padLeft(2, '0')}-'
            '${dateTime.day.toString().padLeft(2, '0')} '
            '${dateTime.hour.toString().padLeft(2, '0')}:'
            '${dateTime.minute.toString().padLeft(2, '0')}:'
            '${dateTime.second.toString().padLeft(2, '0')}';
      } catch (e) {
        // biarkan createdAt apa adanya jika parse gagal
      }
    }

    // support nested menu object atau fields terpisah
    String? menuName;
    String? menuImage;
    double? menuPrice;

    final menuObj = json['menu'] ?? json['menu_item'] ?? json['menuObject'];
    if (menuObj is Map) {
      menuName = (menuObj['name'] ?? menuObj['menu_name'] ?? '').toString();
      menuImage = (menuObj['image'] ?? menuObj['menu_image'] ?? '').toString();
      menuPrice = _parseDouble(menuObj['price'] ?? menuObj['menu_price'], 0.0);
    } else {
      menuName = (json['menu_name'] ?? json['name'])?.toString();
      menuImage = (json['menu_image'] ?? json['image'])?.toString();
      menuPrice = _parseDouble(json['menu_price'] ?? json['price'], 0.0);
      if (menuPrice == 0.0) menuPrice = null;
    }

    return Transaction(
      id: _parseInt(json['id'] ?? 0),
      menuId: _parseInt(json['menu_id'] ?? json['menuId'] ?? 0),
      quantity: _parseInt(json['quantity'] ?? 0),
      totalPrice: _parseDouble(
        json['total_price'] ?? json['totalPrice'] ?? 0.0,
      ),
      paymentMethod: (json['payment_method'] ?? json['paymentMethod'] ?? '')
          .toString(),
      createdAt: createdAt,
      menuName: menuName,
      menuImage: menuImage,
      menuPrice: menuPrice,
    );
  }

  Map<String, dynamic> toJson({
    bool includeId = false,
    bool includeCreatedAt = false,
    // Jika backend mengharapkan nested menu object saat membuat transaksi,
    // set includeMenuAsObject = true (default false untuk kompatibilitas)
    bool includeMenuAsObject = false,
  }) {
    // Pastikan total_price valid: jika tidak diberikan, coba hitung dari menuPrice * quantity
    final computedTotal = (totalPrice > 0.0)
        ? totalPrice
        : ((menuPrice ?? 0.0) * quantity);

    final json = <String, dynamic>{
      'menu_id': menuId,
      'quantity': quantity,
      'total_price': computedTotal,
      'payment_method': paymentMethod,
    };

    if (includeMenuAsObject) {
      json['menu'] = {
        'id': menuId,
        if (menuName != null) 'name': menuName,
        if (menuImage != null) 'image': menuImage,
        if (menuPrice != null) 'price': menuPrice,
      };
    }

    if (includeId && id > 0) {
      json['id'] = id;
    }

    if (includeCreatedAt && createdAt.isNotEmpty) {
      json['created_at'] = createdAt;
    }

    return json;
  }
}
