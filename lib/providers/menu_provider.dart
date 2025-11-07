import 'package:flutter/material.dart';
import '../models/menu_model.dart';
import '../api/caferesto_api.dart';

class MenuProvider extends ChangeNotifier {
  List<Menu> _menus = [];
  bool _isLoading = false;
  String? _error;

  List<Menu> get menus => List.unmodifiable(_menus);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Memuat menu dari API
  Future<void> loadMenus() async {
    if (_isLoading) return; // Jika sedang loading, jangan load lagi

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final menus = await ApiService.fetchMenus();
      _menus = menus;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Gagal memuat menu dari API: $e');
      // Tetap tampilkan data lama jika ada
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat menu di background tanpa blocking UI
  Future<void> loadMenusInBackground() async {
    if (_isLoading) return;

    try {
      final menus = await ApiService.fetchMenus();
      _menus = menus;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat menu dari API: $e');
      // Tetap tampilkan data lama jika ada
    }
  }

  /// Mendapatkan menu berdasarkan ID
  Menu? getMenuById(int id) {
    try {
      return _menus.firstWhere((menu) => menu.id == id);
    } catch (e) {
      return null;
    }
  }
}

