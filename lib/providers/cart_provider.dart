import 'package:flutter/material.dart';
import '../models/caferesto_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<Menu, int> _items = {};

  Map<Menu, int> get items => _items;

  /// Menambahkan item ke keranjang
  void addItem(Menu menu) {
    if (_items.containsKey(menu)) {
      _items[menu] = _items[menu]! + 1;
    } else {
      _items[menu] = 1;
    }
    notifyListeners();
  }

  /// Mengurangi jumlah item, atau menghapus jika jumlahnya 0
  void removeItem(Menu menu) {
    if (_items.containsKey(menu)) {
      if (_items[menu]! > 1) {
        _items[menu] = _items[menu]! - 1;
      } else {
        _items.remove(menu);
      }
      notifyListeners();
    }
  }

  /// Menghitung total harga seluruh pesanan
  double get totalPrice {
    double total = 0;
    _items.forEach((menu, qty) {
      total += menu.price * qty;
    });
    return total;
  }

  /// 🔹 Menghapus semua item dari keranjang (reset)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// (Opsional) Mendapatkan total jumlah semua item
  int get totalItems {
    int total = 0;
    _items.forEach((_, qty) => total += qty);
    return total;
  }
}
