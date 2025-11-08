import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/menu_model.dart';
import '../api/caferesto_api.dart';
import 'package:intl/intl.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  final Map<int, Menu> _menuCache = {};
  int _nextId = -1; // Gunakan ID negatif untuk membedakan ID lokal dengan ID dari server

  List<Transaction> get transactions =>
      List.unmodifiable(_transactions.reversed);

  /// Menambahkan menu ke cache
  void cacheMenu(Menu menu) {
    _menuCache[menu.id] = menu;
  }

  /// Mendapatkan menu dari cache berdasarkan ID
  Menu? getMenuById(int menuId) {
    return _menuCache[menuId];
  }

  /// Menambahkan transaksi untuk setiap item di cart dan menyimpan ke API
  Future<void> addTransactions({
    required Map<Menu, int> items,
    required String paymentMethod,
  }) async {
    final now = DateTime.now();
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final createdAt = dateFormatter.format(now);

    // List untuk menyimpan transaksi yang berhasil
    final List<Transaction> savedTransactions = [];

    // Membuat transaction untuk setiap item di cart dan cache menu
    for (var entry in items.entries) {
      final menu = entry.key;
      final quantity = entry.value;

      // Cache menu untuk akses nanti
      cacheMenu(menu);

      final transaction = Transaction(
        id: 0, // ID akan diisi oleh server
        menuId: menu.id,
        quantity: quantity,
        totalPrice: menu.price * quantity,
        paymentMethod: paymentMethod,
        createdAt: createdAt,
      );

      try {
        // Menyimpan transaksi ke API
        final savedTransaction = await ApiService.createTransaction(
          transaction,
        );
        
        // Langsung tambahkan ke list jika berhasil (tidak perlu validasi tambahan)
        if (savedTransaction.id > 0) {
          savedTransactions.add(savedTransaction);
        } else {
          // Jika ID 0, gunakan transaksi lokal
          final localTransaction = Transaction(
            id: _nextId--,
            menuId: menu.id,
            quantity: quantity,
            totalPrice: menu.price * quantity,
            paymentMethod: paymentMethod,
            createdAt: createdAt,
          );
          savedTransactions.add(localTransaction);
        }
      } catch (error) {
        // Jika gagal ke API, simpan lokal saja
        final localTransaction = Transaction(
          id: _nextId--,
          menuId: menu.id,
          quantity: quantity,
          totalPrice: menu.price * quantity,
          paymentMethod: paymentMethod,
          createdAt: createdAt,
        );
        savedTransactions.add(localTransaction);
        debugPrint('⚠️ Gagal ke API, disimpan lokal: ${menu.name}');
      }
    }

    // Langsung tambahkan semua transaksi ke riwayat (tidak perlu validasi)
    _transactions.addAll(savedTransactions);
    notifyListeners();
    
    debugPrint('✅ ${savedTransactions.length} transaksi ditambahkan ke riwayat');
  }

  /// Menghapus transaksi berdasarkan ID
  void removeTransaction(int id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  /// Menghapus semua transaksi
  void clearTransactions() {
    _transactions.clear();
    _nextId = -1;
    notifyListeners();
  }

  /// Mendapatkan total jumlah transaksi
  int get totalTransactions => _transactions.length;

  /// Mengelompokkan transaksi berdasarkan waktu (untuk menampilkan sebagai satu pesanan)
  Map<String, List<Transaction>> getGroupedTransactions() {
    final Map<String, List<Transaction>> grouped = {};

    for (var transaction in _transactions) {
      final key = transaction.createdAt;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(transaction);
    }

    return grouped;
  }

  /// Memuat transaksi dari API
  Future<void> loadTransactions() async {
    try {
      // Memuat transaksi dan menu secara terpisah untuk menghindari error jika salah satu gagal
      List<Transaction> transactions = [];
      List<Menu> menus = [];

      // Memuat transaksi
      try {
        transactions = await ApiService.fetchTransactions();
        
        // Merge data dari API dengan data lokal (jangan hapus data lokal yang belum tersimpan ke API)
        // Buat map untuk tracking transaksi yang sudah ada di API
        final Map<String, Transaction> apiTransactionsMap = {};
        for (var t in transactions) {
          // Gunakan kombinasi menu_id, quantity, total_price, dan created_at sebagai key unik
          final key = '${t.menuId}_${t.quantity}_${t.totalPrice}_${t.createdAt}';
          apiTransactionsMap[key] = t;
        }
        
        // Simpan data lokal yang belum ada di API
        final List<Transaction> localOnlyTransactions = [];
        for (var localT in _transactions) {
          final key = '${localT.menuId}_${localT.quantity}_${localT.totalPrice}_${localT.createdAt}';
          // Jika transaksi lokal tidak ada di API dan memiliki ID negatif (ID lokal), berarti belum tersimpan ke API
          if (!apiTransactionsMap.containsKey(key) && localT.id < 0) {
            localOnlyTransactions.add(localT);
          }
        }
        
        // Clear dan replace dengan data dari API + data lokal yang belum tersimpan
        _transactions.clear();
        _transactions.addAll(transactions);
        _transactions.addAll(localOnlyTransactions);
      } catch (e) {
        debugPrint('Gagal memuat transaksi dari API: $e');
        // Jika gagal memuat dari API, tetap pertahankan data lokal
        // Tetap lanjutkan untuk memuat menu
      }

      // Memuat menu
      try {
        menus = await ApiService.fetchMenus();
        // Update cache menu (selalu update untuk memastikan data terbaru termasuk imageUrl)
        for (var menu in menus) {
          cacheMenu(menu);
        }
      } catch (e) {
        debugPrint('Gagal memuat menu dari API: $e');
        // Jika gagal memuat menu, tetap lanjutkan dengan data yang ada
      }

      // Memastikan semua menu untuk transaksi ter-cache
      if (transactions.isNotEmpty && menus.isNotEmpty) {
        final menuIdsInTransactions = transactions.map((t) => t.menuId).toSet();
        for (var menuId in menuIdsInTransactions) {
          if (!_menuCache.containsKey(menuId)) {
            // Jika menu belum ada di cache, cari dari menu yang sudah dimuat
            final menu = menus.firstWhere(
              (m) => m.id == menuId,
              orElse: () => Menu(
                id: menuId,
                name: 'Menu ID: $menuId',
                price: 0,
                category: '',
                imageUrl: '',
              ),
            );
            cacheMenu(menu);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error saat memuat data: $e');
      // Jika gagal, tetap tampilkan data lokal yang ada
      notifyListeners();
    }
  }

  /// Memuat menu dari API jika belum ada di cache
  Future<void> ensureMenuCached(int menuId) async {
    if (_menuCache.containsKey(menuId)) {
      return; // Menu sudah ada di cache
    }

    try {
      // Memuat semua menu dari API
      final menus = await ApiService.fetchMenus();
      for (var menu in menus) {
        cacheMenu(menu);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat menu dari API: $e');
    }
  }
}
