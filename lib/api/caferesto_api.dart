import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  static const String baseUrl =
      "https://python-flask-3awan-caferesto-production.up.railway.app/api"; // emulator Android

  static Future<List<Menu>> fetchMenus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menus'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Menu.fromJson(item)).toList();
      } else {
        throw Exception(
          'Gagal memuat data menu: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error saat memuat menu: $e');
    }
  }

  /// Menyimpan transaksi ke API
  static Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final jsonBody = transaction.toJson();
      final jsonString = jsonEncode(jsonBody);

      print('📤 Mengirim transaksi ke API: $baseUrl/transactions');
      print('Body: $jsonString');

      http.Response response;
      try {
        response = await http
            .post(
              Uri.parse('$baseUrl/transactions'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonString,
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'Request timeout: Server tidak merespons dalam 30 detik',
                );
              },
            );
      } on SocketException catch (e) {
        throw Exception(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda: ${e.message}',
        );
      } on http.ClientException catch (e) {
        throw Exception(
          'Gagal terhubung ke server. Periksa koneksi internet atau URL API: $e',
        );
      } catch (e) {
        final errorMsg = e.toString();
        if (errorMsg.contains('Failed to fetch') ||
            errorMsg.contains('NetworkError') ||
            errorMsg.contains('Connection') ||
            errorMsg.contains('timeout') ||
            errorMsg.contains('Timeout')) {
          throw Exception(
            'Gagal terhubung ke server. Periksa koneksi internet Anda dan pastikan server API dapat diakses. Error: $errorMsg',
          );
        }
        if (errorMsg.contains('Request timeout')) {
          throw Exception(
            'Request timeout: Server tidak merespons. Silakan coba lagi.',
          );
        }
        rethrow;
      }

      print('📥 Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonData;
        try {
          jsonData = jsonDecode(response.body);
        } catch (e) {
          throw Exception(
            'Gagal parse response JSON: $e. Response: ${response.body}',
          );
        }

        // Handle jika response adalah list atau object
        Transaction? savedTransaction;
        if (jsonData is List && jsonData.isNotEmpty) {
          savedTransaction = Transaction.fromJson(
            jsonData.first as Map<String, dynamic>,
          );
        } else if (jsonData is Map<String, dynamic>) {
          savedTransaction = Transaction.fromJson(jsonData);
        } else if (jsonData is Map) {
          savedTransaction = Transaction.fromJson(
            Map<String, dynamic>.from(jsonData),
          );
        } else {
          throw Exception(
            'Format response tidak dikenal: ${jsonData.runtimeType}',
          );
        }

        if (savedTransaction.id > 0) {
          print(
            '✅ Transaksi berhasil disimpan dengan ID: ${savedTransaction.id}',
          );
          return savedTransaction;
        } else {
          throw Exception(
            'ID transaksi tidak valid (ID: ${savedTransaction.id}). Response: ${response.body}',
          );
        }
      } else {
        // Handle berbagai status code error
        String errorMessage = 'Gagal menyimpan transaksi';
        if (response.statusCode == 400) {
          errorMessage = 'Bad Request - Format data tidak valid';
        } else if (response.statusCode == 404) {
          errorMessage = 'Endpoint tidak ditemukan';
        } else if (response.statusCode == 500) {
          errorMessage = 'Server Error - Terjadi kesalahan di server';
        } else if (response.statusCode == 422) {
          errorMessage = 'Unprocessable Entity - Data tidak dapat diproses';
        }

        print('═══════════════════════════════════════════════════════');
        print('❌ ERROR RESPONSE DARI API');
        print('═══════════════════════════════════════════════════════');
        print('Status Code: ${response.statusCode}');
        print('Error Message: $errorMessage');
        print('Response Body: ${response.body}');
        print('═══════════════════════════════════════════════════════');

        throw Exception(
          '$errorMessage (Status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR SAAT MENYIMPAN TRANSAKSI');
      print('═══════════════════════════════════════════════════════');
      print('Error: $e');
      print('═══════════════════════════════════════════════════════');
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
        throw Exception(
          'Gagal memuat data transaksi: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error saat memuat transaksi: $e');
    }
  }
}
