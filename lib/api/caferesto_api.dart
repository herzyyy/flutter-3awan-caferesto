import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  static const String baseUrl = "https://python-flask-3awan-caferesto-production.up.railway.app"; // emulator Android

  static Future<List<Menu>> fetchMenus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menus'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Menu.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data menu: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat memuat menu: $e');
    }
  }

  /// Menyimpan transaksi ke API
  static Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        // Handle jika response adalah list atau object
        if (jsonData is List && jsonData.isNotEmpty) {
          return Transaction.fromJson(jsonData.first as Map<String, dynamic>);
        } else if (jsonData is Map<String, dynamic>) {
          return Transaction.fromJson(jsonData);
        } else if (jsonData is Map) {
          return Transaction.fromJson(Map<String, dynamic>.from(jsonData));
        } else {
          // Jika response tidak sesuai format, return transaction yang dikirim
          return transaction;
        }
      } else {
        throw Exception('Gagal menyimpan transaksi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat menyimpan transaksi: $e');
    }
  }

  /// Mengambil semua transaksi dari API
  static Future<List<Transaction>> fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transactions'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data transaksi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat memuat transaksi: $e');
    }
  }
}
